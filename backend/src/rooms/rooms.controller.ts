import { Controller, Param, Post, Req, UseGuards } from '@nestjs/common';
import { RoomsService } from './rooms.service';
import { AuthGuard } from '../auth/auth.guard';

type AuthenticatedRequest = Request & {
  playerId: string;
  sessionId: string;
};

@Controller('rooms')
export class RoomsController {
  constructor(private readonly roomsService: RoomsService) {}

  @Post('create')
  @UseGuards(AuthGuard)
  createRoom(@Req() req: AuthenticatedRequest) {
    return this.roomsService.createRoom(req.playerId);
  }

  @Post('join/:code')
  @UseGuards(AuthGuard)
  joinRoom(@Param('code') code: string, @Req() req: AuthenticatedRequest) {
    this.roomsService.joinRoom(code, req.playerId);
  }

  @Post('start/:code')
  startRoom(@Param('code') code: string) {
    this.roomsService.startRoom(code);
  }

  @Post('end/:code')
  endRoom(@Param('code') code: string) {
    this.roomsService.endRoom(code);
  }
}
