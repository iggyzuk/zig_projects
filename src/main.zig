const std = @import("std");
const rl = @import("raylib");
const rlm = @import("raylib-math");

const ArrayList = @import("std").ArrayList;
const allocator = @import("std").heap.c_allocator;

const Random = @import("std").Random.Xoshiro256;

const SCREEN_WIDTH = 800;
const SCREEN_HEIGHT = 600;

const World = struct {
    balls: ArrayList(Ball),
    rng: Random,

    pub fn init() !World {
        const world: World = .{
            .balls = ArrayList(Ball).init(allocator),
            .rng = std.rand.DefaultPrng.init(0),
        };
        return world;
    }

    pub fn createBall(self: *@This()) !Ball {
        const ball = Ball.init(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, 2, 1, &self.rng);
        _ = try self.balls.append(ball);
        return ball;
    }

    pub fn update(self: *@This()) !void {
        for (0..10) |_| {
            _ = try createBall(self);
        }

        for (self.balls.items) |*ball| {
            ball.update();
            ball.draw();
        }
    }
};

const Ball = struct {
    position: rl.Vector2,
    size: f32,
    speed: rl.Vector2,

    pub fn init(x: f32, y: f32, size: f32, speed: f32, rng: *Random) @This() {
        const speedX = (rng.random().float(f32) - 0.5) * 2 * speed;
        const speedY = (rng.random().float(f32) - 0.5) * 2 * speed;

        return Ball{
            .position = rl.Vector2.init(x, y),
            .size = size,
            .speed = rl.Vector2.init(speedX, speedY),
        };
    }

    pub fn update(self: *@This()) void {
        self.position = rlm.vector2Add(self.position, self.speed);

        // check for y collisions
        if (self.position.y <= self.size or self.position.y >= SCREEN_HEIGHT - self.size) {
            self.speed.y *= -1;
        }

        // check for x collisions
        if (self.position.x <= self.size or self.position.x >= SCREEN_WIDTH - self.size) {
            self.speed.x *= -1;
        }
    }

    pub fn draw(self: *@This()) void {
        rl.drawCircleV(self.position, self.size, rl.Color.red);
    }
};

pub fn main() anyerror!void {
    rl.initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "balls");
    defer rl.closeWindow();

    var world = try World.init();

    // main fame loop
    rl.setTargetFPS(60);
    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.init(18, 18, 18, 255));

        try world.update();
    }
}
