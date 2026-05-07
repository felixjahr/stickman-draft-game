import { Body, Controller, Post } from '@nestjs/common';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  constructor(private auth: AuthService) {}

  @Post('guest')
  createGuest(@Body() body: { name?: string }) {
    return this.auth.createGuestAccount(body.name);
  }

  @Post('refresh')
  refresh(@Body() body: { refresh_token: string }) {
    return this.auth.refresh(body.refresh_token);
  }
}
