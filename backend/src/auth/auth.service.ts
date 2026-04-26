import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../prisma.service';
import { ulid } from 'ulid';
import * as bcrypt from 'bcrypt';
import { randomBytes } from 'crypto';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwt: JwtService,
  ) {}

  private createRefreshToken(): string {
    return randomBytes(64).toString('base64url');
  }

  private async createAccessToken(playerId: string, sessionId: string) {
    return this.jwt.signAsync({
      sub: playerId,
      sid: sessionId,
    });
  }

  async createGuestAccount() {
    const playerId = ulid();
    const sessionId = ulid();
    const refreshToken = this.createRefreshToken();

    await this.prisma.player.create({
      data: {
        id: playerId,
        sessions: {
          create: {
            id: sessionId,
            refreshTokenHash: await bcrypt.hash(refreshToken, 12),
          },
        },
      },
    });

    return {
      player_id: playerId,
      access_token: await this.createAccessToken(playerId, sessionId),
      refresh_token: refreshToken,
    };
  }

  async refresh(refreshToken: string) {
    const sessions = await this.prisma.session.findMany();

    for (const session of sessions) {
      const matches = await bcrypt.compare(
        refreshToken,
        session.refreshTokenHash,
      );

      if (matches) {
        return {
          player_id: session.playerId,
          access_token: await this.createAccessToken(
            session.playerId,
            session.id,
          ),
          refresh_token: refreshToken,
        };
      }
    }

    throw new UnauthorizedException('Invalid refresh token');
  }

  async verifyAccessToken(accessToken: string) {
    try {
      return await this.jwt.verifyAsync(accessToken);
    } catch {
      throw new UnauthorizedException('Invalid access token');
    }
  }
}
