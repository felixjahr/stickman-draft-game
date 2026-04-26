import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { AuthService } from './auth.service';

@Injectable()
export class AuthGuard implements CanActivate {
  constructor(private auth: AuthService) {}

  async canActivate(context: ExecutionContext) {
    const req = context.switchToHttp().getRequest();

    const header = req.headers.authorization;

    if (!header || !header.startsWith('Bearer ')) {
      throw new UnauthorizedException('Missing access token');
    }

    const accessToken = header.slice('Bearer '.length);
    const payload = await this.auth.verifyAccessToken(accessToken);

    req.playerId = payload.sub;
    req.sessionId = payload.sid;

    return true;
  }
}
