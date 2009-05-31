#import "TMMoveToApplicationsFolder.h"

static TMMoveToApplicationsFolder *applicationMover = NULL;
static NSString *TMDefaultKeyHasCheckedApplicationFolder = @"TMHasCheckedApplicationFolder";
static NSString *newPath = NULL;

@interface TMMoveToApplicationsFolder (Private)

#pragma mark Determining if the move should be made

/*
 Returns true if this is the first launch.
 */

- (BOOL) shouldCheckApplicationFolder;

/*
 Returns true if the application is in the Applications folder.
 */

- (BOOL) applicationIsInApplicationsFolder;

#pragma mark Prompting the user

/*
 Displays an alert asking the user if they would like to move the program to the
 Applications folder.
 */

- (void) displayAlert;

#pragma mark Performing the move

/*
 Moves the application to the Applications folder.
 */

- (void) moveApplication;

/*
 Displays an alert informing the user that the program could not be moved.
 */

- (void) displayMoveError:(NSError *)error;

/*
 Sets a preference indicating that the launch check has occurred and should not
 occur again.
 */

#pragma mark Post-move cleanup

- (void) setHasCheckedFolder;

/*
 Quits the program and relaunches it from the Applications folder.
 */

- (void) relaunch;

#pragma mark Pseudo-properties

/*
 Returns the path to the current application bundle directory.
 */

- (NSString *) currentPath;

/*
 Returns the path to the application bundle directory if it were in the
 Applications folder.
 */

- (NSString *) newPath;

/*
 Returns the name of the application.
 */

- (NSString *) programName;

@end

#pragma mark -

@implementation TMMoveToApplicationsFolder

#pragma mark Working with the singleton instance

+ (TMMoveToApplicationsFolder *) applicationMover {
	@synchronized(self) {
		if (applicationMover == NULL) [[self alloc] init];
	}
	return applicationMover;
}

/*
 Ensures that someone else cannot directly allocate space for another instance.
 */

+ (id) allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (applicationMover == NULL) {
			applicationMover = [super allocWithZone:zone];
			return applicationMover;
		}
	}
	return NULL;
}

/*
 Ensures singleton status by disallowing copies.
 */

- (id) copyWithZone:(NSZone *)zone {
	return self;
}

/*
 Prevents this object from being retained.
 */

- (id) retain {
	return self;
}

/*
 Indicates that this object is not memory-managed.
 */

- (NSUInteger) retainCount {
	return NSUIntegerMax;
}

/*
 Prevents this object from being released.
 */

- (void) release {
	
}

/*
 Prevents this object from being added to an autorelease pool.
 */

- (id) autorelease {
	return self;
}

#pragma mark Prompting the user to move the program

- (void) checkApplicationFolder {
	if ([self shouldCheckApplicationFolder]) {
		if (![self applicationIsInApplicationsFolder]) [self displayAlert];
		[self setHasCheckedFolder];
	}
}

@end

#pragma mark -

@implementation TMMoveToApplicationsFolder (Private)

#pragma mark Determining if the move should be made

- (BOOL) shouldCheckApplicationFolder {
	return ![[NSUserDefaults standardUserDefaults] boolForKey:TMDefaultKeyHasCheckedApplicationFolder];
}

- (BOOL) applicationIsInApplicationsFolder {
	NSArray *appPath = [[self currentPath] pathComponents];
	return ([[appPath objectAtIndex:([appPath count] - 2)] isEqualToString:@"Applications"]);
}

#pragma mark Prompting the user

- (void) displayAlert {
	NSAlert *alert = [[NSAlert alloc] init];
	NSString *messageText = [[NSString alloc] initWithFormat:NSLocalizedString(@"Would you like to place %@ in the Applications folder?", NULL), [self programName]];
	[alert setMessageText:messageText];
	[messageText release];
	[alert setInformativeText:NSLocalizedString(@"Most applications are installed into this folder, but you can run this program from any folder if you wish.", @"this = the Applications folder")];
	[alert setAlertStyle:NSInformationalAlertStyle];
	[alert addButtonWithTitle:NSLocalizedString(@"Move", @"this program to a different folder")];
	[alert addButtonWithTitle:NSLocalizedString(@"Don't Move", @"this program to a different folder")];
	[alert setShowsHelp:YES];
	[alert setHelpAnchor:@"move_application"];
	NSInteger result = [alert runModal];
	if (result == NSAlertFirstButtonReturn) [self moveApplication];
	[alert release];
}

#pragma mark Performing the move

- (void) moveApplication {
	NSError *error = NULL;
	BOOL result = [[NSFileManager defaultManager] copyItemAtPath:[self currentPath] toPath:[self newPath] error:&error];
	if (result) {
		NSArray *files = [[NSArray alloc] initWithObject:[[self currentPath] lastPathComponent]];
		NSInteger tag = 0;
		[[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation source:[[self currentPath] stringByDeletingLastPathComponent] destination:@"" files:files tag:&tag];
		[files release];
		[self relaunch];
	}
	else [self displayMoveError:error];
	
}

- (void) displayMoveError:(NSError *)error {
	NSAlert *alert = [[NSAlert alloc] init];
	[alert setAlertStyle:NSCriticalAlertStyle];
	NSString *messageText = [[NSString alloc] initWithFormat:NSLocalizedString(@"%@ could not be copied to the Applications folder.", NULL), [self programName]];
	[alert setMessageText:messageText];
	[messageText release];
	[alert setInformativeText:[error localizedDescription]];
	[alert addButtonWithTitle:NSLocalizedString(@"OK", @"command")];
	[alert runModal];
	[alert release];
}

#pragma mark Post-move cleanup

- (void) setHasCheckedFolder {
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:TMDefaultKeyHasCheckedApplicationFolder];
}

- (void) relaunch {
	[[NSWorkspace sharedWorkspace] openFile:[self newPath]];
	[[NSApplication sharedApplication] terminate:self];
}

#pragma mark Pseudo-properties

- (NSString *) currentPath {
	return [[NSBundle mainBundle] bundlePath];
}

- (NSString *) newPath {
	if (!newPath) {
		NSString *bundleName = [[self currentPath] lastPathComponent];
		newPath = [[@"/Applications" stringByAppendingPathComponent:bundleName] retain];
	}
	return newPath;
}

- (NSString *) programName {
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
}

@end
