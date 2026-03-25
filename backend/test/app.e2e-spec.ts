import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { MongoMemoryServer } from 'mongodb-memory-server';
import { AppModule } from '../src/app.module';

describe('App (e2e)', () => {
  let app: INestApplication;
  let mongo: MongoMemoryServer;
  let httpServer: ReturnType<INestApplication['getHttpServer']>;

  beforeAll(async () => {
    mongo = await MongoMemoryServer.create();
    process.env.MONGODB_URI = mongo.getUri();
    process.env.JWT_SECRET = 'e2e-jwt-secret-not-for-production';
    process.env.NODE_ENV = 'test';

    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
      }),
    );
    await app.init();
    httpServer = app.getHttpServer();
  });

  afterAll(async () => {
    await app.close();
    await mongo.stop();
  });

  it('GET /health — Mongo reachable', () => {
    return request(httpServer).get('/health').expect(200);
  });

  it('GET /faqs — public, no auth', () => {
    return request(httpServer)
      .get('/faqs')
      .expect(200)
      .expect((res) => {
        expect(Array.isArray(res.body)).toBe(true);
      });
  });

  it('GET /deliveries — 401 without token', () => {
    return request(httpServer).get('/deliveries').expect(401);
  });

  it('POST /auth/register/customer + GET /deliveries with Bearer', async () => {
    const email = `e2e-${Date.now()}@example.test`;
    const register = await request(httpServer)
      .post('/auth/register/customer')
      .send({
        email,
        password: 'password1',
        name: 'E2E Customer',
      })
      .expect(201);

    const token = register.body?.access_token as string | undefined;
    expect(token).toBeDefined();
    expect(typeof token).toBe('string');

    await request(httpServer)
      .get('/deliveries')
      .set('Authorization', `Bearer ${token}`)
      .expect(200)
      .expect((res) => {
        expect(Array.isArray(res.body)).toBe(true);
      });
  });

  it('POST /deliveries — customer creates delivery + GET by id', async () => {
    const email = `e2e-del-${Date.now()}@example.test`;
    const register = await request(httpServer)
      .post('/auth/register/customer')
      .send({
        email,
        password: 'password1',
        name: 'E2E Delivery Customer',
      })
      .expect(201);

    const token = register.body?.access_token as string;

    const created = await request(httpServer)
      .post('/deliveries')
      .set('Authorization', `Bearer ${token}`)
      .send({
        pickupLocation: 'Pickup A',
        deliveryAddress: 'Dropoff B',
        deliveryType: 'Food',
      })
      .expect(201);

    const id = created.body?._id as string | undefined;
    expect(id).toBeDefined();

    await request(httpServer)
      .get(`/deliveries/${id}`)
      .set('Authorization', `Bearer ${token}`)
      .expect(200)
      .expect((res) => {
        expect(res.body.pickupLocation).toBe('Pickup A');
        expect(res.body.deliveryAddress).toBe('Dropoff B');
      });
  });
});
