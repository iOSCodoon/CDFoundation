//
//  CDCoreDataManager.m
//  CodoonSport
//
//  Created by Jinxiao on 5/29/15.
//  Copyright (c) 2015 Codoon. All rights reserved.
//

#import "CDCoreDataManager.h"

@interface CDCoreDataManager ()
@property (readwrite, nonatomic, strong) NSManagedObjectContext *masterManagedObjectContext;
@property (readwrite, nonatomic, strong) NSManagedObjectContext *branchManagedObjectContext;
@property (readwrite, nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (readwrite, nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

@implementation CDCoreDataManager

+ (instancetype)sharedInstance
{
    static id instance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = self.new;
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if(self != nil)
    {
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinatorWithStoreType:NSSQLiteStoreType storeURL:[self sqliteStoreURL]];
        
        _masterManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _masterManagedObjectContext.persistentStoreCoordinator = coordinator;
        _masterManagedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
        [_masterManagedObjectContext obtainPermanentIDsBeforeSaving];
        
        _branchManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _branchManagedObjectContext.parentContext = _masterManagedObjectContext;
        [_branchManagedObjectContext mergeChangesFromContextAfterSaving:_masterManagedObjectContext];
        [_branchManagedObjectContext obtainPermanentIDsBeforeSaving];
    }
    return self;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorWithStoreType:(NSString *)storeType storeURL:(NSURL *)storeURL
{
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @YES, NSInferMappingModelAutomaticallyOption : @YES};
    
    NSError *error = nil;
    if(![coordinator addPersistentStoreWithType:storeType configuration:nil URL:storeURL options:options error:&error])
    {
        if(error != nil)
        {
            BOOL migrationError = (error.code == NSPersistentStoreIncompatibleVersionHashError || error.code == NSMigrationMissingSourceModelError || error.code == NSMigrationError);
            if(migrationError)
            {
                [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
                [[NSFileManager defaultManager] removeItemAtURL:[NSURL URLWithString:[storeURL.absoluteString stringByAppendingString:@"-shm"] ] error:nil];
                [[NSFileManager defaultManager] removeItemAtURL:[NSURL URLWithString:[storeURL.absoluteString stringByAppendingString:@"-wal"] ] error:nil];
                
                [coordinator addPersistentStoreWithType:storeType configuration:nil URL:storeURL options:options error:nil];
            }
        }
        else
        {
            NSLog(@"ERROR WHILE CREATING PERSISTENT STORE COORDINATOR! %@, %@", error, [error userInfo]);
        }
    }
    
    return coordinator;
}

- (NSString *)appName
{
    return [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleName"];
}

- (NSString *)databaseName
{
    if(!_databaseName)
    {
        _databaseName = [[[self appName] stringByAppendingString:@".sqlite"] copy];
    }
    return _databaseName;
}

- (NSString *)modelName
{
    if(!_modelName)
    {
        _modelName = [[self appName] copy];
    }
    return _modelName;
}

- (NSURL *)sqliteStoreURL
{
    NSURL *filePath = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath.absoluteString])
    {
        [[NSFileManager defaultManager] createDirectoryAtURL:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return [filePath URLByAppendingPathComponent:[self databaseName]];
}

@end
