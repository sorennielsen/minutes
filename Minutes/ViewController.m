//
//  ViewController.m
//  Minutes
//
//  Created by Filip Jakobsen on 02/01/14.
//  Copyright (c) 2014 stronger. All rights reserved.
//

#import "ViewController.h"
#import <math.h>

@interface ViewController () {
    BOOL paused;
    int secondsCount;
    NSTimer *countdownTimer;
    
    int beforePanSecondsCount;
    CGFloat panPixelSeconds;
    int selectedSeconds;
    
    NSArray *notificationQuotes;
    int notificationFireDateInSeconds;
    
    UIPanGestureRecognizer *panRecognizer;
    UITapGestureRecognizer *tapRecognizer;
    UITapGestureRecognizer *doubleTapRecognizer;
}
@end

@implementation ViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Font size:
    [countdownLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:800.0]];
    countdownLabel.adjustsFontSizeToFitWidth = YES;
    
    // App becoming inactive/active:
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillBecomeInactive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];

    // Panning:
    panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(minutesScrolling)];
    [self.view addGestureRecognizer:panRecognizer];
    
    // Single tap:
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleCountdown)];
    [self.view addGestureRecognizer:tapRecognizer];
    tapRecognizer.numberOfTapsRequired = 1;
    
    // Double tap:
    doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetToSelectedSeconds)];
    [self.view addGestureRecognizer:doubleTapRecognizer];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    
    // Sound:
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    
    // Quotes:
    [self populateNotificationQuotes];
    
    // Initialize stop watch:
    selectedSeconds = 600;
    [self resetToSelectedSeconds];
}

- (void) appDidBecomeActive:(NSNotification *)notification {
    if (paused) return;
    secondsCount = fmax(0, notificationFireDateInSeconds - [[NSDate date] timeIntervalSinceReferenceDate]);
    [self updateDisplay];
    if (secondsCount == 0) [self pauseCountdown:YES];
    else [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void) appWillBecomeInactive:(NSNotification *)notification {
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void) toggleCountdown {
    if (secondsCount == 0) [self resetToSelectedSeconds];
    else if (paused) [self startCountdown];
    else [self pauseCountdown:YES];
}

- (void) startCountdown {
    [self scheduleNotification];
    countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(aSecondHasPassed) userInfo:nil repeats:YES];
    paused = NO;
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void) pauseCountdown:(BOOL)cancelNotification {
    [countdownTimer invalidate];
    countdownTimer = nil;
    paused = YES;
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    if (cancelNotification) [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void) aSecondHasPassed {
    secondsCount -= 1;
    [self updateDisplay];
    if (secondsCount == 0) [self pauseCountdown:NO];
}

- (void) minutesScrolling {
    if (!paused) return;
    
    if (panRecognizer.state == UIGestureRecognizerStateBegan) {
        beforePanSecondsCount = secondsCount;
        panPixelSeconds = 3600.0f / [self screenHeight];
    }
    
    secondsCount = beforePanSecondsCount - ([panRecognizer translationInView:self.view].y * panPixelSeconds);
    if (secondsCount < 0) secondsCount += 3600;
    if (secondsCount > 3600) secondsCount -= 3600;
    int stepMins = 1;
    secondsCount = (((secondsCount / 60) / stepMins) + 1) * stepMins * 60;
    selectedSeconds = secondsCount;
    
    [self updateDisplay];
}

- (void) resetToSelectedSeconds {
    [self pauseCountdown:YES];
    secondsCount = selectedSeconds;
    [self updateDisplay];
}

- (void) updateDisplay {
    int minutes = secondsCount / 60;
    int seconds = secondsCount - (minutes * 60);
    countdownLabel.text = [NSString stringWithFormat:@"%.2d.%.2d", minutes, seconds];
}

- (void) scheduleNotification {
    UILocalNotification* notification = [[UILocalNotification alloc] init];
    NSUInteger randomIndex = arc4random() % [notificationQuotes count];
    notification.alertBody = [[NSString alloc] initWithFormat:@"%@", notificationQuotes[randomIndex]];
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:secondsCount];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.soundName = @"bell.mp3";
    notification.userInfo = [NSDictionary dictionaryWithObject:@"1234" forKey:@"IDkey"];
    notification.applicationIconBadgeNumber = 0;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    notificationFireDateInSeconds = [notification.fireDate timeIntervalSinceReferenceDate];
}

- (void) populateNotificationQuotes {
    notificationQuotes = @[
                           //MISC
                           @"If opportunity doesn't knock, build a door -Milton Berle",
                           @"An obstacle is often a stepping stone - Prescott Bush",
                           @"Wisdom begins in wonder -Socrates",
                           @"Winners never quit and quitters never win -Vince Lombardi",
                           @"Nobody can give you wiser advice than yourself -Cicero",
                           @"A prudent question is one-half of wisdom -Francis Bacon",
                           @"To conquer fear is the beginning of wisdom -Bertrand Russell",
                           @"The only source of knowledge is experience -Albert Einstein",
                           @"Experience is the teacher of all things -Julius Caesar",
                           @"Experience is a good school. But the fees are high -H. Heine",
                           @"Experience teaches only the teachable -Aldous Huxley",
                           //TIME
                           @"Lost time is never found again -Benjamin Franklin",
                           @"You may delay, but time will not -Benjamin Franklin",
                           @"The time is always right to do what is right -M. L. King, Jr.",
                           @"The time you enjoy wasting is not wasted time -B. Russell",
                           @"Don't wait. The time will never be just right -Napoleon Hill",
                           @"We must use time creatively -Martin Luther King, Jr.",
                           //DREAMS
                           @"Dreams are today's answers to tomorrow's questions -E. Cayce",
                           //FREINDSHIP
                           @"Be true to your work, your word, and your friend -Thoreau",
                           //Happiness
                           @"The purpose of our lives is to be happy -Dalai Lama",
                           //imagination
                           @"Imagination creates reality -Richard Wagner",
                           //Inspirational
                           @"Don't let the fear of striking out hold you back. -Babe Ruth",
                           @"It is always the simple that produces the marvelous. -A. Barr",
                           @"Whoever is happy will make others happy too -Anne Frank",
                           @"In a gentle way, you can shake the world -Mahatma Gandhi",
                           @"A compliment is something like a kiss through a veil -V. Hugo",
                           @"When deeds speak, words are nothing -Pierre-Joseph Proudhon",
                           @"For a gallant spirit there can never be defeat -Wallis Simpson",
                           @"Enthusiasm moves the world -Arthur Balfour",
                           @"You miss 100% of the shots you don't take -Wayne Gretzky",
                           @"Look back, and smile on perils past -Walter Scott",
                           @"A smile is a curve that sets everything straight -Phyllis Diller",
                           @"A smile is the universal welcome -Max Eastman",
                           @"Smile, it's free therapy -Douglas Horton",
                           @"I truly believe my job is to make sure people smile -S. Khan",
                           //Random
                           @"Wherever you go, go with all your heart -Confucius",
                           @"He who is contented is rich -Lao Tzu",
                           @"You are what you settle for –Janis Joplin",
                           @"Uncertainty is a signpost of possibility -Jonathan Fields",
                           @"Work without love is slavery -Mother Teresa",
                           @"Work Hard, have fun, make history -Jeff Bezos",
                           @"Freedom lies in being bold -Robert Frost",
                           @"The important thing is not to stop questioning -Albert Einstein",
                           @"Don't fight forces, use them -R. Buckminster Fuller",
                           @"Integrity is the essence of everything successful. ―Fuller",
                           @"The more you know, the less you need -Yvon Chouinard",
                           @"Consume less, but better -Yvon Chouinard",
                           @"Creativity is the greatest rebellion in existence. -Osho",
                           @"Play is the highest form of research -Albert Einstein",
                           @"Critics build nothing -Robert Moses",
                           @"The measure of intelligence is the ability to change -Einstein",
                           @"I do not seek, I find -Pablo Picasso",
                           @"I'm not a businessman, I'm a business, man -Jay-Z",
                           @"Working hard is a skill you have to nurture -Chris Shiflett",
                           @"Invest your life in what you love! -Jessica Jackley",
                           @"Dare to be naive -Buckminster Fuller",
                           @"Make it simple but significant! -Don Draper in Mad Men",
                           @"You can't build a reputation on what you're going to do -Henry Ford",
                           @"Be so good they can't ignore you -Steve Martin",
                           @"Say yes, and you'll figure it out afterward! -Tina Fey",
                           @"Think Long. Write Short -George Lois",
                           @"Creativity is the residue of time wasted -Albert Einstein",
                           @"Silent gratitude isn't much use to anyone -Gladys B. Stern",
                           @"Good habits are worth being fanatical about -John Irving",
                           @"Creativity takes courage -Henri Matisse",
                           @"If it isn't beautiful, it probably shouldn't be at all -Yves Behar",
                           @"Whatever you are, be a good one! -Abraham Lincoln",
                           @"You can do anything, but not everything -David Allen",
                           @"Take your pleasure seriously -Charles Eames",
                           @"The creative mind plays with the objects it loves -Carl Jung",
                           @"No one looks stupid when they're having fun -Amy Poehler",
                           @"Play in curiosity is where everything happens -Andrew Zuckerman",
                           @"Complaining is stupid. Either act or forget -Stefan Sagmeister",
                           @"You're never too old to become younger -Mae West",
                           @"A labor of love always pays off! -Scott Belsky",
                           @"Creativity is not a talent. It is a way of operating -John Cleese",
                           @"Collaboration is a good way to step away from ego -Joshua Davis",
                           @"Most quarrels amplify a misunderstanding -Andre Gide",
                           @"You are a mashup of what you let into your life -Austin Kleon",
                           @"Stay hungry. Stay foolish - Stewart Brand",
                           @"The best way to complain is to make things -James Murphy",
                           @"Smooth seas do not make skillful sailors -African Proverb",
                           @"First ponder, then dare -Helmut von Moltke",
                           @"You don't need a plan, you need skills and a problem -37signals",
                           @"The details are not details. They make the product -Charles Eames",
                           @"Simplicity is complexity resolved -Constantin Brancusi",
                           @"Because I am critical does not mean I am right -Rob Roy Kelly",
                           @"What is life, but a series of inspired follies? -G. Bernard Shaw",
                           //Simplicity
                           @"Life is really simple, but we insist on making it complicated -Confucius",
                           @"Simplicity is the ultimate sophistication -Leonardo da Vinci",
                           @"The art of being wise is the art of knowing what to overlook. -W. James",
                           @"It is vain to do with more what can be done with less. -William of Occam"
                           ];
}

- (CGFloat) screenHeight {
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        return [UIScreen mainScreen].bounds.size.height;
    }
    return [UIScreen mainScreen].bounds.size.width * 2.0f;
}

@end
