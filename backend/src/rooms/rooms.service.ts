import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { spawn } from 'child_process';
import { randomInt } from 'crypto';
import { RoomsGateway } from './rooms.gateway';
import { Room } from './room.types';

const ROOM_SIZE = 2;
const GAME_IP = '127.0.0.1';
const GAME_BASE_PORT = 9000;
const GAME_PORT_RANGE_SIZE = 1000;
const SERVER_PATH = '/usr/local/bin/docker';

@Injectable()
export class RoomsService {
  private readonly rooms = new Map<string, Room>();
  private nextGamePort = GAME_BASE_PORT;

  constructor(private readonly roomsGateway: RoomsGateway) {}

  createRoom(sessionId: string): { code: string } {
    if (!this.roomsGateway.hasSession(sessionId)) {
      throw new BadRequestException('Invalid session');
    }

    const code = this.generateRoomCode();

    const room: Room = {
      code,
      gameId: 'draft',
      mapId: this.pickRandomMap(),
      members: [sessionId],
      status: 'waiting',
    };

    this.rooms.set(code, room);

    return { code };
  }

  joinRoom(code: string, sessionId: string): void {
    if (!this.roomsGateway.hasSession(sessionId)) {
      throw new BadRequestException('Invalid session');
    }

    const room = this.rooms.get(code);
    if (!room) {
      throw new NotFoundException('Room not found');
    }

    if (!(room.status === 'waiting')) {
      throw new BadRequestException('Room already started');
    }

    if (room.members.length >= ROOM_SIZE) {
      throw new BadRequestException('Room is full');
    }

    room.members.push(sessionId);

    if (room.members.length === ROOM_SIZE) {
      this.startServer(room);
    }
  }

  startRoom(code: string): void {
    const room = this.rooms.get(code);
    if (!room) {
      throw new NotFoundException('Room not found');
    }
    if (!room.ip || !room.port) {
      throw new BadRequestException('Room has no allocated endpoint');
    }

    room.status = 'ready';

    for (const sessionId of room.members) {
      this.roomsGateway.sendRoomStart(sessionId, room.ip, room.port);
    }
  }

  private startServer(room: Room): void {
    room.status = 'starting';
    room.port = this.allocatePort();
    room.ip = GAME_IP;

    const args = [
      'run',
      '--platform',
      'linux/amd64',
      '-p',
      `${room.port}:${room.port}/udp`,
      '-v',
      '/Users/felixjahr/Documents/Projects/Stickman Draft Game/export/server:/app',
      'ubuntu:24.04',
      '/app/server.x86_64',
      '--headless',
      `port=${room.port}`,
      `code=${room.code}`,
      `game_id=${room.gameId}`,
      `map_id=${room.mapId}`,
    ];

    spawn(SERVER_PATH, args, { stdio: 'inherit' });
  }

  private allocatePort(): number {
    const port = this.nextGamePort;
    this.nextGamePort =
      GAME_BASE_PORT +
      ((this.nextGamePort - GAME_BASE_PORT + 1) % GAME_PORT_RANGE_SIZE);
    return port;
  }

  private generateRoomCode(): string {
    let code = '';
    do {
      code = randomInt(0, 10000).toString().padStart(4, '0');
    } while (this.rooms.has(code));
    return code;
  }

  private pickRandomMap(): string {
    const maps = ['forest', 'mountains'];
    return maps[Math.floor(Math.random() * maps.length)];
  }
}
