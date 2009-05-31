/*!
 @class TMMoveToApplicationsFolder
 @abstract Singleton class that can check if the application is being run from
 the Applications folder, and if not, offer to move it there for the user.
 
 The program does not have to be in /Applications, but can also be in
 ~/Applications, or within any directory named "Applications" in order to
 suppress the prompt.
 
 The move is accomplished by copying the program to the /Applications folder,
 moving the running copy to the trash, launching the new copy, and quitting the
 current copy.
 */

@interface TMMoveToApplicationsFolder : NSObject {
	
}

#pragma mark Working with the singleton instance

/*!
 @method applicationMover
 @abstract Returns the singleton instance.
 */

+ (TMMoveToApplicationsFolder *) applicationMover;

#pragma mark Prompting the user to move the program

/*!
 @method checkApplicationFolder
 @abstract This method should be run when the application is first launched. It
 will offer to move the application to the Applications folder if it's not
 already in that folder. This offer is only made once, on the first launch.
 */

- (void) checkApplicationFolder;

@end
