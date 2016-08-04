//
//  PHSMyScene.m
//  FoggyFrog
//
//  Created by Patel, Amit on 12/30/13.
//  Copyright (c) 2013 Patel, Amit. All rights reserved.
//

#import "PHSMyScene.h"
#import "PHSViewController.h"
#import "PHSGameDataModel.h"

static const int countdownMaxTimeInSeconds = 25;
static const uint32_t tongueCategory     =  0x1 << 0;
static const uint32_t dragonFlyCategory  =  0x1 << 1;
static BOOL doneOnce = NO;
static int count = countdownMaxTimeInSeconds;

static inline CGPoint addPoints(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint subtractPoints(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint scalePoint(CGPoint a, float b) {
    return CGPointMake(a.x * b, a.y * b);
}

static inline float lengthOfPoint(CGPoint a) {
    return sqrtf(a.x * a.x + a.y * a.y);
}

// Makes a vector have a length of 1
static inline CGPoint normalizePoint(CGPoint a) {
    float length = lengthOfPoint(a);
    return CGPointMake(a.x / length, a.y / length);
}



@interface PHSMyScene()  <SKPhysicsContactDelegate>
{
    NSMutableArray *dragonFlys;
    NSInteger killCount;
    CGFloat redBlendFactor;
    SKLabelNode* frogText;
    SKLabelNode* countDownText;
    SKSpriteNode* frog;
    SKSpriteNode* pond;
    SKSpriteNode* snake;
    UITapGestureRecognizer *singleTapGesture;
    UITapGestureRecognizer *doubleTapGesture;
}

-(void) addPond;
-(void) addFrog;
-(void) addDragonFly;
-(void) addFoggyFrogSaysText;
-(void) makeFrogJump:(CGPoint)point;
-(void) moveDragonFly:(SKSpriteNode*) dragonFly;
-(void) doDoubleTap;
-(void) doSingleTap;
-(void) attemptToCatchDragonFly;
-(void) countdownTimer;
-(void) startTimer;

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast;

@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@end

@implementation PHSMyScene

-(instancetype)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
        dragonFlys = [[NSMutableArray alloc] initWithCapacity:72];
        killCount = 0;
        redBlendFactor = 0.0f;
        frogText = nil;
        countDownText = nil;
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
        singleTapGesture = nil;
        doubleTapGesture = nil;
        self.paused = YES;
    }
    return self;
}

- ( void ) willMoveFromView: (SKView *) view {
    
    [super willMoveFromView:view];
    [view removeGestureRecognizer:doubleTapGesture];
    
    [view removeGestureRecognizer:singleTapGesture];
    
}

-(void) didMoveToView: (SKView *) view
{
    [super didMoveToView:view];
    singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(doSingleTap)];
    singleTapGesture.numberOfTapsRequired = 1;
    [view addGestureRecognizer:singleTapGesture];
    
    doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(doDoubleTap)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [view addGestureRecognizer:doubleTapGesture];
    
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    
}

-(void) dealloc
{
    [self cleanup];
}

-(void) cleanup
{
    [self removeAllActions];
    [self removeAllChildren];
    for (SKSpriteNode* node in dragonFlys)
    {
        [node removeFromParent];
    }
    if (frogText)
    {
        [frogText removeFromParent];
        frogText = nil;
    }
    if (countDownText)
    {
        [countDownText removeFromParent];
        countDownText = nil;
    }
    if (frog)
    {
        [frog removeFromParent];
        frog = nil;
    }
    if (pond)
    {
        [pond removeFromParent];
        pond = nil;
    }
    killCount = 0;
    doneOnce = NO;
    count = countdownMaxTimeInSeconds;
    if (dragonFlys && dragonFlys.count > 0)
    {
        [dragonFlys removeAllObjects];
        dragonFlys = nil;
        
    }
    self.paused = YES;
}



-(void) makeFrogJump:(CGPoint)point
{
    SKAction * actionMoveUp = [SKAction moveTo:point duration:0.2];
    CGPoint pointDown = CGPointMake(point.x, pond.position.y);
    SKAction* actionMoveDown =[SKAction moveTo:pointDown duration: 0.2];
    [frog runAction:[SKAction sequence:@[actionMoveUp, actionMoveDown]]];
}

-(void) addFoggyFrogSaysText
{
    if (frogText == nil)
    {
        frogText = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Normal"];
        frogText.text = @"Single Tap to move Foggy Frog!\n   Double Tap to catch a DragonFly!";
        frogText.fontSize = 16;
        frogText.fontColor = [SKColor greenColor];
        frogText.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [self addChild:frogText];
        SKAction * actionFade = [SKAction fadeAlphaBy:1.0f duration:2.0];
        SKAction * actionMoveDone = [SKAction removeFromParent];
        [frogText runAction:[SKAction sequence:@[actionFade, actionMoveDone]]];
        frogText = nil;

    }
}


- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast
{
    NSTimeInterval speed = 1.0;
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > speed /* this is x */)
    {
        self.lastSpawnTimeInterval = 0;
        if (self.paused == YES)
        {
            return;
        }
        if (doneOnce == NO)
        {
            [self addPond];
//            [self addSnake];
            [self addFrog];
            NSInteger level = [self.controller.dataModel.gameLevel integerValue];
            if (level < 2)
                level = 2;
            for(NSInteger i = 0; i < level/2; i++)
            {
                [self addDragonFly];
            }
            [self addFoggyFrogSaysText];
            count = countdownMaxTimeInSeconds;
            doneOnce = YES;
        }
        for (SKSpriteNode* sprite in dragonFlys)
        {
            [self moveDragonFly:sprite];
        }
    }
}


-(void)update:(CFTimeInterval)currentTime {
    [super update:currentTime];

    /* Called before each frame is rendered */
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast >= 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    static NSTimeInterval timeCheck = 0.0;
    timeCheck+=timeSinceLast;
    if (timeCheck >= 1.0)
    {
        count--;
        NSLog(@"count is %d", count);
        timeCheck = 0.0;
        if (count <= 0)
        {
            count = 0;
            NSNumber* timesUp = [NSNumber numberWithInteger:1];
            [self.controller.dataModel setValue:timesUp forKey:@"timesUpCount"];
        }
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
}

-(void) addPond
{
    if (pond == nil)
    {
        pond = [SKSpriteNode spriteNodeWithImageNamed:@"pond"];
        [pond setScale:0.6f];
        pond.zPosition = -1.0f;
        CGPoint pos;
        pos.x = 0.0f;
        pos.y = 30.0f;
        pond.position = pos;
        [self addChild:pond];
    }
}

-(void) addFrog
{
    if (frog == nil)
    {
        frog = [SKSpriteNode spriteNodeWithImageNamed:@"froghappy"];
        frog.name = @"frog";
        [frog setScale:0.1f];
        frog.position = CGPointMake(self.frame.size.width/2, pond.position.y);
        frog.zPosition = 1.0f;
        [self addChild:frog];
    }


}


-(void) addDragonFly
{
    SKSpriteNode* dragonFly = [SKSpriteNode spriteNodeWithImageNamed:@"dragonfly.png"];
    dragonFly.name = @"dragonfly";
    [dragonFly setScale:0.05f];
//    CGPoint position = CGPointMake(self.frame.size.width/4, self.frame.size.height/4);
    dragonFly.position = CGPointMake(200, 200);
    dragonFly.zPosition = 1.0f;
    dragonFly.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:dragonFly.size];
    dragonFly.physicsBody.dynamic = YES;
    dragonFly.physicsBody.affectedByGravity = YES;
    dragonFly.physicsBody.angularDamping = 0.1f;
    dragonFly.physicsBody.linearDamping = 0.2f;
    dragonFly.physicsBody.allowsRotation = YES;
    dragonFly.physicsBody.categoryBitMask = dragonFlyCategory;
    dragonFly.physicsBody.contactTestBitMask = tongueCategory;
    dragonFly.physicsBody.collisionBitMask = 0;
    dragonFly.physicsBody.usesPreciseCollisionDetection = YES;
    [self addChild:dragonFly];
    if (dragonFlys == nil)
        dragonFlys = [[NSMutableArray alloc] initWithCapacity:72];
    [dragonFlys addObject:dragonFly];
    
}

-(void) moveDragonFly:(SKSpriteNode*) dragonFly
{
    int x = arc4random() % (int)self.frame.size.width +1;
    int y = arc4random() % (int)self.frame.size.height +1;
    CGPoint point = CGPointMake(x/1.0f, y/1.0f);
    dragonFly.zPosition = 1.0f;
    NSTimeInterval duration = 2.5;
    NSInteger level = [self.controller.dataModel.gameLevel integerValue];
    if (level > 5)
        duration = 2.0;
    else if (level > 10)
        duration = 1.5;
    else if (level > 15 && level < 20)
        duration = 1.0;
    else if (level > 20)
        duration = 0.5;
    
    SKAction * actionMove = [SKAction moveTo:point duration:duration];
    [dragonFly runAction:[SKAction sequence:@[actionMove]]];
}



-(void)didSimulatePhysics
{
    [super didSimulatePhysics];
}

- (void)projectile:(SKSpriteNode *)projectile didCollideWithDragonFly:(SKSpriteNode *)dragonfly {
    NSLog(@"Hit");
    [dragonfly removeAllActions];
    SKAction* killDragonFly = [SKAction moveTo:frog.position duration:0.1];
    SKAction* fadeDragonFly = [SKAction fadeAlphaBy:0.6f duration:0.1];
    SKAction* removeNode = [SKAction removeFromParent];
    [dragonfly runAction:[SKAction sequence:@[killDragonFly, fadeDragonFly, removeNode]]];
    SKAction* frogAteDragonFly = [SKAction scaleBy:1.5f duration:0.1];
    [frog runAction:[SKAction sequence:@[frogAteDragonFly, frogAteDragonFly.reversedAction]]];

    killCount+=1;
    [dragonFlys removeObject:dragonfly];
    NSNumber* killedDragonFlies = [NSNumber numberWithInteger:killCount];
    [self.controller.dataModel setValue:killedDragonFlies forKey:@"killCount"];
//    [self runAction:[SKAction playSoundFileNamed:@"killedAWasp.m4a" waitForCompletion:NO]];
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    // 1
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    // 2
    if ((firstBody.categoryBitMask & tongueCategory) != 0 &&
        (secondBody.categoryBitMask & dragonFlyCategory) != 0)
    {
        [self projectile:(SKSpriteNode *) firstBody.node didCollideWithDragonFly:(SKSpriteNode *) secondBody.node];
    }
}

-(void) attemptToCatchDragonFly
{
    CGPoint location = [doubleTapGesture locationOfTouch:0 inView:doubleTapGesture.view];
    CGPoint actualLocation = [self convertPointFromView:location];
    
    // 2 - Set up initial location of projectile
    SKSpriteNode * projectile = [SKSpriteNode spriteNodeWithImageNamed:@"tongue"];
    [projectile setScale:0.2f];
    projectile.position = frog.position;
    projectile.zPosition = 2.0f;
    projectile.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:projectile.size];
    projectile.physicsBody.dynamic = YES;
    projectile.physicsBody.categoryBitMask = tongueCategory;
    projectile.physicsBody.contactTestBitMask = dragonFlyCategory;
    projectile.physicsBody.collisionBitMask = 0;
    projectile.physicsBody.usesPreciseCollisionDetection = YES;
    
    // 3- Determine offset of location to projectile
    CGPoint offset = subtractPoints(actualLocation, projectile.position);
    
    // 4 - Do NOT Bail out if you are shooting down or backwards
    CGPoint originPoint = CGPointMake(actualLocation.x - frog.position.x, actualLocation.y - frog.position.y); // get origin point to origin by subtracting end from start
    float bearingRadians = atan2f(originPoint.y, originPoint.x); // get bearing in radians
    float angle = bearingRadians;
    if (projectile.zRotation < 0)
    {
        projectile.zRotation = projectile.zRotation + M_PI * 2;
    }
    SKAction* actionRotate = [SKAction rotateByAngle:angle duration:0.05f];
    // 5 - OK to add now - we've double checked position
    [self addChild:projectile];
    
    // 6 - Get the direction of where to shoot
    CGPoint direction = normalizePoint(offset);
    
    // 7 - Make it shoot far enough to be guaranteed off screen
    CGPoint shootAmount = scalePoint(direction, 300);
    
    // 8 - Add the shoot amount to the current position
    CGPoint realDest = addPoints(shootAmount, projectile.position);
    
    // 9 - Create the actions
    float velocity = 480.0f/0.4f;
    float realMoveDuration = self.size.width / velocity;
    SKAction * actionMove = [SKAction moveTo:realDest duration:realMoveDuration];
    SKAction* actionMoveBack = [SKAction moveTo:frog.position duration:realMoveDuration/2.0];
    //SKAction* actionMove = [SKAction moveByX:realDest.x y:realDest.y duration:realMoveDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [projectile runAction:[SKAction sequence:@[actionRotate, actionMove, actionMoveBack, actionMoveDone]]];
}

-(void) doDoubleTap
{
    [self attemptToCatchDragonFly];
    NSLog(@"kill count is %ld", (long)killCount);
}

-(void) doSingleTap
{
    CGPoint point = [singleTapGesture locationOfTouch:0 inView:singleTapGesture.view];
    CGPoint actualPoint = [self convertPointFromView:point];
    [self makeFrogJump:actualPoint];
}

// Sprite Kit timer.  Use for countdown in seconds
-(void) countdownTimer
{
    if (self.paused == YES)
        return;
    
    if (countDownText == nil)
    {
        countDownText = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Normal"];
        countDownText.text = [NSString stringWithFormat:@"Timer: %d",count];
        countDownText.fontSize = 10;
        countDownText.fontColor = [SKColor redColor];
        CGFloat height = 0.0f;
        height = self.frame.size.height - countDownText.fontSize;
        countDownText.position = CGPointMake(self.frame.size.width - 25, height);
        [self addChild:countDownText];
    }
    else
    {
        countDownText.text = [NSString stringWithFormat:@"Timer: %d",count];
        SKAction * actionFade = [SKAction fadeAlphaBy:1.0f duration:0.2];
        [countDownText runAction:[SKAction sequence:@[actionFade]]];
    }
}

-(void) startTimer
{
    self.paused = NO;
    count = countdownMaxTimeInSeconds;
    SKAction *wait = [SKAction waitForDuration:1.0];
    SKAction *performSelector = [SKAction performSelector:@selector(countdownTimer) onTarget:self];
    SKAction *sequence = [SKAction sequence:@[wait, performSelector]];
    SKAction *repeat   = [SKAction repeatActionForever:sequence];
    [self runAction:repeat];
}

-(void) stopTimer
{
    [countDownText removeAllActions];
    count = countdownMaxTimeInSeconds;
    self.paused = YES;
    return;
}

@end
