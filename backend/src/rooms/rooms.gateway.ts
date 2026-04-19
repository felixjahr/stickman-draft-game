import {
  OnGatewayConnection,
  OnGatewayDisconnect,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { randomUUID } from 'crypto';
import type { Server, WebSocket } from 'ws';

@WebSocketGateway({
  path: '/ws',
})
export class RoomsGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private readonly sessions = new Map<string, WebSocket>();
  private readonly socketToSession = new Map<WebSocket, string>();

  handleConnection(client: WebSocket): void {
    const sessionId = randomUUID();

    this.sessions.set(sessionId, client);
    this.socketToSession.set(client, sessionId);

    client.send(
      JSON.stringify({
        event: 'session',
        data: { sessionId },
      }),
    );
  }

  handleDisconnect(client: WebSocket): void {
    const sessionId = this.socketToSession.get(client);
    if (!sessionId) return;

    this.socketToSession.delete(client);
    this.sessions.delete(sessionId);
  }

  hasSession(sessionId: string): boolean {
    return this.sessions.has(sessionId);
  }

  sendRoomStart(sessionId: string, ip: string, port: number): void {
    const socket = this.sessions.get(sessionId);
    if (!socket || socket.readyState !== socket.OPEN) return;

    socket.send(
      JSON.stringify({
        event: 'receiveRoomStart',
        data: { ip, port },
      }),
    );
  }
}
