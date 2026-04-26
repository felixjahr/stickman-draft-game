import {
  OnGatewayConnection,
  OnGatewayDisconnect,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import type { Server, WebSocket } from 'ws';
import { AuthService } from '../auth/auth.service';

@WebSocketGateway({
  path: '/ws',
})
export class RoomsGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private readonly playerSockets = new Map<string, WebSocket>();
  private readonly socketPlayers = new Map<WebSocket, string>();

  constructor(private readonly authService: AuthService) {}

  handleConnection(client: WebSocket): void {
    client.on('message', async (raw) => {
      try {
        const text = raw.toString();
        const msg = JSON.parse(text);

        if (msg?.event !== 'auth') {
          return;
        }

        const accessToken = msg?.data?.accessToken;
        if (!accessToken) {
          client.close();
          return;
        }

        const payload = await this.authService.verifyAccessToken(accessToken);
        const playerId = payload.sub;

        this.playerSockets.set(playerId, client);
        this.socketPlayers.set(client, playerId);

        client.send(
          JSON.stringify({
            event: 'authOk',
            data: {
              playerId,
            },
          }),
        );
      } catch {
        client.close();
      }
    });
  }

  handleDisconnect(client: WebSocket): void {
    const playerId = this.socketPlayers.get(client);
    if (!playerId) return;

    this.socketPlayers.delete(client);
    this.playerSockets.delete(playerId);
  }

  hasPlayer(playerId: string): boolean {
    return this.playerSockets.has(playerId);
  }

  sendRoomStart(
    playerId: string,
    ip: string,
    port: number,
    gameToken: string,
  ): void {
    const socket = this.playerSockets.get(playerId);
    if (!socket || socket.readyState !== socket.OPEN) return;

    socket.send(
      JSON.stringify({
        event: 'receiveRoomStart',
        data: { ip, port, gameToken },
      }),
    );
  }
}
