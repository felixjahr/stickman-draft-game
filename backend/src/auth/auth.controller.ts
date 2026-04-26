import { Body, Controller, Post } from '@nestjs/common';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  constructor(private auth: AuthService) {}

  @Post('guest')
  createGuest() {
    return this.auth.createGuestAccount();
  }

  @Post('refresh')
  refresh(@Body() body: { refresh_token: string }) {
    return this.auth.refresh(body.refresh_token);
  }
}
