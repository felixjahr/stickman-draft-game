import {
  BadRequestException,
  Controller,
  Headers,
  Param,
  Post,
} from '@nestjs/common';
import { RoomsService } from './rooms.service';

@Controller('rooms')
export class RoomsController {
  constructor(private readonly roomsService: RoomsService) {}

  @Post('create')
  createRoom(@Headers('x-session-id') sessionId?: string) {
    if (!sessionId) {
      throw new BadRequestException('Missing x-session-id header');
    }

    return this.roomsService.createRoom(sessionId);
  }

  @Post('join/:code')
  joinRoom(
    @Param('code') code: string,
    @Headers('x-session-id') sessionId?: string,
  ) {
    if (!sessionId) {
      throw new BadRequestException('Missing x-session-id header');
    }

    this.roomsService.joinRoom(code, sessionId);
  }

  @Post('start/:code')
  startRoom(@Param('code') code: string) {
    this.roomsService.startRoom(code);
  }
}
