import { Test, TestingModule } from '@nestjs/testing';
import { AppModule } from './app.module';

describe('AppModule', () => {
  let module: TestingModule;

  beforeEach(async () => {
    module = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();
  });

  it('should be defined', () => {
    expect(module).toBeDefined();
  });

  it('should compile successfully', () => {
    const appModule = module.get<AppModule>(AppModule);
    expect(appModule).toBeInstanceOf(AppModule);
  });

  afterEach(async () => {
    await module.close();
  });
});
