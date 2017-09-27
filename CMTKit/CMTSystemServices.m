//
//  CMTSystemServices.m
//  MedicalForum
//
//  Created by fenglei on 14/12/2.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTSystemServices.h"
#import "CMTSystemServicesConstants.h"
#import "CMTOPENUDID.h"

@implementation CMTSystemServices

#pragma mark Lifecycle
// Singleton
+ (instancetype)sharedServices {
    static CMTSystemServices *sharedSystemServices = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSystemServices = [[self alloc] init];
    });
    return sharedSystemServices;
}

// System Information
- (NSString *)deviceModel {
    static NSString *DeviceModel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Get the device model
        if ([[UIDevice currentDevice] respondsToSelector:@selector(model)]) {
            // Make a string for the device model
            DeviceModel = [[UIDevice currentDevice] model];
        } else {
            // Device model not found
            DeviceModel = nil;
        }
    });
    // Set the output to the device model
    return DeviceModel;
}

- (NSString *)deviceName {
    static NSString *DeviceName;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Get the current device name
        if ([[UIDevice currentDevice] respondsToSelector:@selector(name)]) {
            // Make a string for the device name
            DeviceName = [[UIDevice currentDevice] name];
        } else {
            // Device name not found
            DeviceName = nil;
        }
    });
    // Set the output to the device model
    return DeviceName;
}

- (NSString *)systemName {
    static NSString *SystemName;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Get the current system name
        if ([[UIDevice currentDevice] respondsToSelector:@selector(systemName)]) {
            // Make a string for the system name
            SystemName = [[UIDevice currentDevice] systemName];
        } else {
            // System name not found
            SystemName = nil;
        }
    });
    // Set the output to the system name
    return SystemName;
}

- (NSString *)systemsVersion {
    static NSString *SystemVersion;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Get the current system version
        if ([[UIDevice currentDevice] respondsToSelector:@selector(systemVersion)]) {
            // Make a string for the system version
            SystemVersion = [[UIDevice currentDevice] systemVersion];
        } else {
            // System version not found
            SystemVersion = nil;
        }
    });
    // Set the output to the system version
    return SystemVersion;
}

- (BOOL)systemVersionGreaterThan:(NSString *)version {
    return [[self systemsVersion] compare:version options:NSNumericSearch] == NSOrderedDescending;
}

- (BOOL)systemVersionNotLessThan:(NSString *)version {
    return [[self systemsVersion] compare:version options:NSNumericSearch] != NSOrderedAscending;
}

- (BOOL)systemVersionEqualTo:(NSString *)version {
    return [[self systemsVersion] compare:version options:NSNumericSearch] == NSOrderedSame;
}

- (BOOL)systemVersionNotGreaterThan:(NSString *)version {
    return [[self systemsVersion] compare:version options:NSNumericSearch] != NSOrderedDescending;
}

- (BOOL)systemVersionLessThan:(NSString *)version {
    return [[self systemsVersion] compare:version options:NSNumericSearch] == NSOrderedAscending;
}

- (NSString *)systemDeviceTypeNotFormatted {
    static NSString *SystemDeviceTypeNotFormatted;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SystemDeviceTypeNotFormatted = [self systemDeviceTypeOfFormatted:NO];
    });
    return SystemDeviceTypeNotFormatted;
}

- (NSString *)systemDeviceTypeFormatted {
    static NSString *SystemDeviceTypeFormatted;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SystemDeviceTypeFormatted = [self systemDeviceTypeOfFormatted:YES];
    });
    return SystemDeviceTypeFormatted;
}

- (NSInteger)screenWidth {
    static NSInteger Width;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Get the screen width
        @try {
            // Screen bounds
            CGRect Rect = [[UIScreen mainScreen] bounds];
            // Find the width (X)
            Width = Rect.size.width;
            // Verify validity
            if (Width <= 0) {
                // Invalid Width
                Width = -1;
            }
        }
        @catch (NSException *exception) {
            // Error
            Width = -1;
        }
    });
    return Width;
}

- (NSInteger)screenHeight {
    static NSInteger Height;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Get the screen height
        @try {
            // Screen bounds
            CGRect Rect = [[UIScreen mainScreen] bounds];
            // Find the Height (Y)
            Height = Rect.size.height;
            // Verify validity
            if (Height <= 0) {
                // Invalid Height
                Height = -1;
            }
        }
        @catch (NSException *exception) {
            // Error
            Height = -1;
        }
    });
    return Height;
}

- (float)screenBrightness {
    static float Brightness;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Get the screen brightness
        @try {
            // Brightness
            Brightness = [UIScreen mainScreen].brightness;
            // Verify validity
            if (Brightness < 0.0 || Brightness > 1.0) {
                // Invalid brightness
                Brightness = -1;
            }
        }
        @catch (NSException *exception) {
            // Error
            Brightness = -1;
        }
    });
    return (Brightness * 100);
}

- (CGFloat)screenWidthRatio {
    static CGFloat ScreenWidthRatio;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Get the screen width ratio
        @try {
            // Ratio
            ScreenWidthRatio = [self screenWidth] / (CGFloat)320;
            // Verify validity
            if (ScreenWidthRatio <= 0.0) {
                // Invalid ratio
                ScreenWidthRatio = -1;
            }
        }
        @catch (NSException *exception) {
            // Error
            ScreenWidthRatio = -1;
        }
    });
    return ScreenWidthRatio;
}

- (CGFloat)xxxscreenWidthRatio {
    static CGFloat xxxScreenWidthRatio;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Get the screen width ratio
        @try {
            // Ratio
            xxxScreenWidthRatio = [self screenWidth] / (CGFloat)414;
            // Verify validity
            if (xxxScreenWidthRatio <= 0.0) {
                // Invalid ratio
                xxxScreenWidthRatio = -1;
            }
        }
        @catch (NSException *exception) {
            // Error
            xxxScreenWidthRatio = -1;
        }
    });
    return xxxScreenWidthRatio;
}

- (NSInteger)screenHeightSizeModel {
    static NSInteger ScreenHeightSizeModel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Get the screen height size model
        @try {
            // Size model
            CGFloat ScreenHeight = [self screenHeight];
            if (ScreenHeight <= 0.0) {
                ScreenHeightSizeModel = -1;
            }
            else {
                ScreenHeightSizeModel = ScreenHeight <= 480 ? 1 : 0;
            }
        }
        @catch (NSException *exception) {
            // Error
            ScreenHeightSizeModel = -1;
        }
    });
    return ScreenHeightSizeModel;
}

- (CGFloat)screenScale {
    static CGFloat ScreenScale;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Get the scale factor with the screen
        @try {
            // Scale
            ScreenScale = [[UIScreen mainScreen] scale];
            // Verify validity
            if (ScreenScale <= 0.0) {
                // Invalid scale
                ScreenScale = -1;
            }
        }
        @catch (NSException *exception) {
            // Error
            ScreenScale = -1;
        }
    });
    return ScreenScale;
}

- (CGFloat)onePixelLineHeight {
    static CGFloat OnePixelLineHeight;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Get the height in point for 1px line
        @try {
            // Height
            OnePixelLineHeight = (CGFloat)1.0 / [self screenScale];
            // Verify validity
            if (OnePixelLineHeight <= 0.0) {
                // Invalid height
                OnePixelLineHeight = -1;
            }
        }
        @catch (NSException *exception) {
            // Error
            OnePixelLineHeight = -1;
        }
    });
    return OnePixelLineHeight;
}

- (NSString *)applicationIdentifier {
    static NSString *Identifier;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Get the Application Identifier
        @try {
            // Query the plist for the identifier
            Identifier = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey];
            // Validate the identifier
            if (Identifier == nil || Identifier.length <= 0) {
                // Invalid bundle identifier
                Identifier = nil;
            }
        }
        @catch (NSException *exception) {
            // Error
            Identifier = nil;
        }
    });
    return Identifier;
}

- (NSString *)applicationName {
    static NSString *Name;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Get the Application Bundle Name
        @try {
            // Query the plist for name
            Name = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
            // Validate the name
            if (Name == nil || Name.length <= 0) {
                // Invalid bundle name
                Name = nil;
            }
        }
        @catch (NSException *exception) {
            // Error
            Name = nil;
        }
    });
    return Name;
}

- (NSString *)applicationDisplayName {
    static NSString *DisplayName;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Get the Application Bundle DisplayName
        @try {
            // Query the plist for displayName
            DisplayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
            // Validate the displayName
            if (DisplayName == nil || DisplayName.length <= 0) {
                // Invalid bundle displayName
                DisplayName = nil;
            }
        }
        @catch (NSException *exception) {
            // Error
            DisplayName = nil;
        }
    });
    return DisplayName;
}

- (NSString *)applicationVersion {
    static NSString *Version;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Get the Application Version Number
        @try {
            // Query the plist for the version
            Version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
            // Validate the version
            if (Version == nil || Version.length <= 0) {
                // Invalid version number
                Version = nil;
            }
        }
        @catch (NSException *exception) {
            // Error
            Version = nil;
        }
    });
    return Version;
}

- (NSString *)applicationBuild {
    static NSString *Build;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Get the Application Build Number
        @try {
            // Query the plist for the build
            Build = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
            // Validate the build
            if (Build == nil || Build.length <= 0) {
                // Invalid build number
                Build = nil;
            }
        }
        @catch (NSException *exception) {
            // Error
            Build = nil;
        }
    });
    return Build;
}

- (NSString *)applicationVersionBuild {
    static NSString *ApplicationVersionBuild;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Get the Application Version + Build Number
        @try {
            // Create a string for the VersionBuild
            ApplicationVersionBuild = [NSString stringWithFormat:@"%@.%@", [self applicationVersion], [self applicationBuild]];
            // Validate the VersionBuild
            if (ApplicationVersionBuild == nil || ApplicationVersionBuild.length <= 0) {
                // Invalid build number
                ApplicationVersionBuild = nil;
            }
        }
        @catch (NSException *exception) {
            // Error
            ApplicationVersionBuild = nil;
        }
    });
    return ApplicationVersionBuild;
}

- (NSString *)clipboardContent {
    NSString *ClipboardContent;
    // Get the string content of the clipboard (copy, paste)
    @try {
        // Get the Pasteboard
        UIPasteboard *PasteBoard = [UIPasteboard generalPasteboard];
        // Get the string value of the pasteboard
        ClipboardContent = [PasteBoard string];
        // Check for validity
        if (ClipboardContent == nil || ClipboardContent.length <= 0) {
            // Error, invalid pasteboard
            ClipboardContent = nil;
        }
    }
    @catch (NSException *exception) {
        // Error
        ClipboardContent = nil;
    }
    return ClipboardContent;
}

- (NSString *)distribution {
    static NSString *Distribution;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Set the name of the Distribution
        Distribution = @"App Store";
//        Distribution = @"other Channel";
    });
    return Distribution;
}

- (NSString *)CMTUDID {
    static NSString *CMTUDID;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Get the UDID
        @try {
            // Get the OpenUDID
            CMTUDID = [CMTOPENUDID value];
            // Validate the UDID
            if (CMTUDID == nil || CMTUDID.length <= 0) {
                // Invalid UDID
                CMTUDID = nil;
            }
        }
        @catch (NSException *exception) {
            // Error
            CMTUDID = nil;
        }
    });
    return CMTUDID;
}

- (NSString *)UserAgent {
    static NSString *UserAgent;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Get the User-Agent
        @try {
            // Create a string for the User-Agent
            UserAgent = [NSString stringWithFormat:@"%@_%@_%@ %@_%@_%@_%@_%@",
                         [self applicationName],
                         [self applicationVersionBuild],
                         [self systemDeviceTypeFormatted],
                         [self systemName],
                         [self systemsVersion],
                         [self distribution],
                         [self CMTUDID],
                         [self cityCode]];
            // Validate the User-Agent
            if (UserAgent == nil || UserAgent.length <= 0) {
                // Invalid User-Agent
                UserAgent = nil;
            }
        }
        @catch (NSException *exception) {
            // Error
            UserAgent = nil;
        }
    });
    return UserAgent;
}

- (NSString *)cellIPAddress {
    NSString *CellIPAddress;
    // Get the Cell IP Address
    @try {
        // Set up structs to hold the interfaces and the temporary address
        struct ifaddrs *Interfaces;
        struct ifaddrs *Temp;
        struct sockaddr_in *s4;
        char buf[64];
        
        // If it's 0, then it's good
        if (!getifaddrs(&Interfaces))
        {
            // Loop through the list of interfaces
            Temp = Interfaces;
            
            // Run through it while it's still available
            while(Temp != NULL)
            {
                // If the temp interface is a valid interface
                if(Temp->ifa_addr->sa_family == AF_INET)
                {
                    // Check if the interface is Cell
                    if([[NSString stringWithUTF8String:Temp->ifa_name] isEqualToString:@"pdp_ip0"])
                    {
                        s4 = (struct sockaddr_in *)Temp->ifa_addr;
                        
                        if (inet_ntop(Temp->ifa_addr->sa_family, (void *)&(s4->sin_addr), buf, sizeof(buf)) == NULL) {
                            // Failed to find it
                            CellIPAddress = nil;
                        } else {
                            // Got the Cell IP Address
                            CellIPAddress = [NSString stringWithUTF8String:buf];
                        }
                    }
                }
                
                // Set the temp value to the next interface
                Temp = Temp->ifa_next;
            }
        }
        
        // Free the memory of the interfaces
        freeifaddrs(Interfaces);
        
        // Check to make sure it's not empty
        if (CellIPAddress == nil || CellIPAddress.length <= 0) {
            // Empty, return not found
            CellIPAddress = nil;
        }
    }
    @catch (NSException *exception) {
        // Error, IP Not found
        CellIPAddress = nil;
    }
    // Return the Cell IP Address
    return CellIPAddress;
}

- (NSString *)cellMACAddress {
    NSString *CellMACAddress;
    // Get the Cell MAC Address
    @try {
        // Start by setting the variables to get the Cell Mac Address
        int                 mgmtInfoBase[6];
        char                *msgBuffer = NULL;
        size_t              length;
        unsigned char       macAddress[6];
        struct if_msghdr    *interfaceMsgStruct;
        struct sockaddr_dl  *socketStruct;
        
        // Setup the management Information Base (mib)
        mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
        mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
        mgmtInfoBase[2] = 0;
        mgmtInfoBase[3] = AF_LINK;        // Request link layer information
        mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
        
        // With all configured interfaces requested, get handle index
        if ((mgmtInfoBase[5] = if_nametoindex([@"pdp_ip0" UTF8String])) == 0) {
            // Error, Name to index failure
            CellMACAddress = nil;
            return CellMACAddress;
        } else {
            // Get the size of the data available (store in len)
            if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0) {
                // Error, Sysctl MgmtInfoBase Failure
                CellMACAddress = nil;
                return CellMACAddress;
            } else {
                // Alloc memory based on above call
                if ((msgBuffer = malloc(length)) == NULL) {
                    // Error, Buffer allocation failure
                    CellMACAddress = nil;
                    return CellMACAddress;
                } else {
                    // Get system information, store in buffer
                    if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0) {
                        // Error, Sysctl MsgBuffer Failure
                        CellMACAddress = nil;
                        return CellMACAddress;
                    }
                }
            }
        }
        
        // Map msgbuffer to interface message structure
        interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
        
        // Map to link-level socket structure
        socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
        
        // Copy link layer address data in socket structure to an array
        memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
        
        // Read from char array into a string object, into traditional Mac address format
        NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                      macAddress[0], macAddress[1], macAddress[2],
                                      macAddress[3], macAddress[4], macAddress[5]];
        
        // Release the buffer memory
        free(msgBuffer);
        
        // Make a new string from the macAddressString
        CellMACAddress = macAddressString;
        
        // If the MAC address comes back empty
        if (CellMACAddress == (id)[NSNull null] || CellMACAddress.length <= 0) {
            // Return that the MAC address was not found
            CellMACAddress = nil;
        }
    }
    @catch (NSException *exception) {
        // Error, return nil
        CellMACAddress = nil;
    }
    return CellMACAddress;
}

- (NSString *)cellNetmaskAddress {
    NSString *CellNetmaskAddress;
    // Get the Cell Netmask Address
    @try {
        // Set up the variable
        struct ifreq afr;
        // Copy the string
        strncpy(afr.ifr_name, [@"pdp_ip0" UTF8String], IFNAMSIZ-1);
        // Open a socket
        int afd = socket(AF_INET, SOCK_DGRAM, 0);
        
        // Check the socket
        if (afd == -1) {
            // Error, socket failed to open
            CellNetmaskAddress = nil;
            return CellNetmaskAddress;
        }
        
        // Check the netmask output
        if (ioctl(afd, SIOCGIFNETMASK, &afr) == -1) {
            // Error, netmask wasn't found
            // Close the socket
            close(afd);
            // Return error
            CellNetmaskAddress = nil;
            return CellNetmaskAddress;
        }
        
        // Close the socket
        close(afd);
        
        // Create a char for the netmask
        char *netstring = inet_ntoa(((struct sockaddr_in *)&afr.ifr_addr)->sin_addr);
        
        // Create a string for the netmask
        CellNetmaskAddress = [NSString stringWithUTF8String:netstring];
        
        // Check to make sure it's not nil
        if (CellNetmaskAddress == nil || CellNetmaskAddress.length <= 0) {
            // Error, netmask not found
            CellNetmaskAddress = nil;
        }
    }
    @catch (NSException *exception) {
        // Error
        CellNetmaskAddress = nil;
    }
    return CellNetmaskAddress;
}

- (NSString *)cellBroadcastAddress {
    NSString *CellBroadcastAddress;
    // Get the Cell Broadcast Address
    @try {
        // Set up strings for the IP and Netmask
        NSString *IPAddress = [self cellIPAddress];
        NSString *NMAddress = [self cellNetmaskAddress];
        
        // Check to make sure they aren't nil
        if (IPAddress == nil || IPAddress.length <= 0) {
            // Error, IP Address can't be nil
            CellBroadcastAddress = nil;
            return CellBroadcastAddress;
        }
        if (NMAddress == nil || NMAddress.length <= 0) {
            // Error, NM Address can't be nil
            CellBroadcastAddress = nil;
            return CellBroadcastAddress;
        }
        
        // Check the formatting of the IP and NM Addresses
        NSArray *IPCheck = [IPAddress componentsSeparatedByString:@"."];
        NSArray *NMCheck = [NMAddress componentsSeparatedByString:@"."];
        
        // Make sure the IP and NM Addresses are correct
        if (IPCheck.count != 4 || NMCheck.count != 4) {
            // Incorrect IP Addresses
            CellBroadcastAddress = nil;
            return CellBroadcastAddress;
        }
        
        // Set up the variables
        NSUInteger IP = 0;
        NSUInteger NM = 0;
        NSUInteger CS = 24;
        
        // Make the address based on the other addresses
        for (NSUInteger i = 0; i < 4; i++, CS -= 8) {
            IP |= [[IPCheck objectAtIndex:i] intValue] << CS;
            NM |= [[NMCheck objectAtIndex:i] intValue] << CS;
        }
        
        // Set it equal to the formatted raw addresses
        NSUInteger BA = ~NM | IP;
        
        // Make a string for the address
        CellBroadcastAddress = [NSString stringWithFormat:@"%lu.%lu.%lu.%lu",
                                (unsigned long)((BA & 0xFF000000) >> 24),
                                (unsigned long)((BA & 0x00FF0000) >> 16),
                                (unsigned long)((BA & 0x0000FF00) >> 8),
                                (unsigned long)(BA & 0x000000FF)];
        
        // Check to make sure the string is valid
        if (CellBroadcastAddress == nil || CellBroadcastAddress.length <= 0) {
            // Error, no address
            CellBroadcastAddress = nil;
        }
    }
    @catch (NSException *exception) {
        // Error
        CellBroadcastAddress = nil;
    }
    return CellBroadcastAddress;
}

- (NSString *)wiFiIPAddress {
    NSString *WiFiIPAddress;
    // Get the WiFi IP Address
    @try {
        // Set up structs to hold the interfaces and the temporary address
        struct ifaddrs *Interfaces;
        struct ifaddrs *Temp;
        // Set up int for success or fail
        int Status = 0;
        
        // Get all the network interfaces
        Status = getifaddrs(&Interfaces);
        
        // If it's 0, then it's good
        if (Status == 0)
        {
            // Loop through the list of interfaces
            Temp = Interfaces;
            
            // Run through it while it's still available
            while(Temp != NULL)
            {
                // If the temp interface is a valid interface
                if(Temp->ifa_addr->sa_family == AF_INET)
                {
                    // Check if the interface is WiFi
                    if([[NSString stringWithUTF8String:Temp->ifa_name] isEqualToString:@"en0"])
                    {
                        // Get the WiFi IP Address
                        WiFiIPAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)Temp->ifa_addr)->sin_addr)];
                    }
                }
                
                // Set the temp value to the next interface
                Temp = Temp->ifa_next;
            }
        }
        
        // Free the memory of the interfaces
        freeifaddrs(Interfaces);
        
        // Check to make sure it's not empty
        if (WiFiIPAddress == nil || WiFiIPAddress.length <= 0) {
            // Empty, return not found
            WiFiIPAddress = nil;
        }
    }
    @catch (NSException *exception) {
        // Error, IP Not found
        WiFiIPAddress = nil;
    }
    return WiFiIPAddress;
}

- (NSString *)wiFiMACAddress {
    NSString *WiFiMACAddress;
    // Get the WiFi MAC Address
    @try {
        // Start by setting the variables to get the WiFi Mac Address
        int                 mgmtInfoBase[6];
        char                *msgBuffer = NULL;
        size_t              length;
        unsigned char       macAddress[6];
        struct if_msghdr    *interfaceMsgStruct;
        struct sockaddr_dl  *socketStruct;
        
        // Setup the management Information Base (mib)
        mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
        mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
        mgmtInfoBase[2] = 0;
        mgmtInfoBase[3] = AF_LINK;        // Request link layer information
        mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
        
        // With all configured interfaces requested, get handle index
        if ((mgmtInfoBase[5] = if_nametoindex([@"en0" UTF8String])) == 0) {
            // Error, Name to index failure
            WiFiMACAddress = nil;
            return WiFiMACAddress;
        } else {
            // Get the size of the data available (store in len)
            if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0) {
                // Error, Sysctl MgmtInfoBase Failure
                WiFiMACAddress = nil;
                return WiFiMACAddress;
            } else {
                // Alloc memory based on above call
                if ((msgBuffer = malloc(length)) == NULL) {
                    // Error, Buffer allocation failure
                    WiFiMACAddress = nil;
                    return WiFiMACAddress;
                } else {
                    // Get system information, store in buffer
                    if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0) {
                        // Error, Sysctl MsgBuffer Failure
                        WiFiMACAddress = nil;
                        return WiFiMACAddress;
                    }
                }
            }
        }
        
        // Map msgbuffer to interface message structure
        interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
        
        // Map to link-level socket structure
        socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
        
        // Copy link layer address data in socket structure to an array
        memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
        
        // Read from char array into a string object, into traditional Mac address format
        NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                      macAddress[0], macAddress[1], macAddress[2],
                                      macAddress[3], macAddress[4], macAddress[5]];
        
        // Release the buffer memory
        free(msgBuffer);
        
        // Make a new string from the macAddressString
        WiFiMACAddress = macAddressString;
        
        // If the MAC address comes back empty
        if (WiFiMACAddress == (id)[NSNull null] || WiFiMACAddress.length <= 0) {
            // Return that the MAC address was not found
            WiFiMACAddress = nil;
        }
    }
    @catch (NSException *exception) {
        // Error, return nil
        WiFiMACAddress = nil;
    }
    return WiFiMACAddress;
}

- (NSString *)wiFiNetmaskAddress {
    NSString *WiFiNetmaskAddress;
    // Get the WiFi Netmask Address
    @try {
        // Set up the variable
        struct ifreq afr;
        // Copy the string
        strncpy(afr.ifr_name, [@"en0" UTF8String], IFNAMSIZ-1);
        // Open a socket
        int afd = socket(AF_INET, SOCK_DGRAM, 0);
        
        // Check the socket
        if (afd == -1) {
            // Error, socket failed to open
            WiFiNetmaskAddress = nil;
            return WiFiNetmaskAddress;
        }
        
        // Check the netmask output
        if (ioctl(afd, SIOCGIFNETMASK, &afr) == -1) {
            // Error, netmask wasn't found
            // Close the socket
            close(afd);
            // Return error
            WiFiNetmaskAddress = nil;
            return WiFiNetmaskAddress;
        }
        
        // Close the socket
        close(afd);
        
        // Create a char for the netmask
        char *netstring = inet_ntoa(((struct sockaddr_in *)&afr.ifr_addr)->sin_addr);
        
        // Create a string for the netmask
        WiFiNetmaskAddress = [NSString stringWithUTF8String:netstring];
        
        // Check to make sure it's not nil
        if (WiFiNetmaskAddress == nil || WiFiNetmaskAddress.length <= 0) {
            // Error, netmask not found
            WiFiNetmaskAddress = nil;
        }
    }
    @catch (NSException *exception) {
        // Error
        WiFiNetmaskAddress = nil;
    }
    return WiFiNetmaskAddress;
}

- (NSString *)wiFiBroadcastAddress {
    NSString *WiFiBroadcastAddress;
    // Get the WiFi Broadcast Address
    @try {
        // Set up strings for the IP and Netmask
        NSString *IPAddress = [self wiFiIPAddress];
        NSString *NMAddress = [self wiFiNetmaskAddress];
        
        // Check to make sure they aren't nil
        if (IPAddress == nil || IPAddress.length <= 0) {
            // Error, IP Address can't be nil
            WiFiBroadcastAddress = nil;
            return WiFiBroadcastAddress;
        }
        if (NMAddress == nil || NMAddress.length <= 0) {
            // Error, NM Address can't be nil
            WiFiBroadcastAddress = nil;
            return WiFiBroadcastAddress;
        }
        
        // Check the formatting of the IP and NM Addresses
        NSArray *IPCheck = [IPAddress componentsSeparatedByString:@"."];
        NSArray *NMCheck = [NMAddress componentsSeparatedByString:@"."];
        
        // Make sure the IP and NM Addresses are correct
        if (IPCheck.count != 4 || NMCheck.count != 4) {
            // Incorrect IP Addresses
            WiFiBroadcastAddress = nil;
            return WiFiBroadcastAddress;
        }
        
        // Set up the variables
        NSUInteger IP = 0;
        NSUInteger NM = 0;
        NSUInteger CS = 24;
        
        // Make the address based on the other addresses
        for (NSUInteger i = 0; i < 4; i++, CS -= 8) {
            IP |= [[IPCheck objectAtIndex:i] intValue] << CS;
            NM |= [[NMCheck objectAtIndex:i] intValue] << CS;
        }
        
        // Set it equal to the formatted raw addresses
        NSUInteger BA = ~NM | IP;
        
        // Make a string for the address
        WiFiBroadcastAddress = [NSString stringWithFormat:@"%lu.%lu.%lu.%lu",
                                (unsigned long)((BA & 0xFF000000) >> 24),
                                (unsigned long)((BA & 0x00FF0000) >> 16),
                                (unsigned long)((BA & 0x0000FF00) >> 8),
                                (unsigned long)(BA & 0x000000FF)];
        
        // Check to make sure the string is valid
        if (WiFiBroadcastAddress == nil || WiFiBroadcastAddress.length <= 0) {
            // Error, no address
            WiFiBroadcastAddress = nil;
        }
    }
    @catch (NSException *exception) {
        // Error
        WiFiBroadcastAddress = nil;
    }
    return WiFiBroadcastAddress;
}

- (BOOL)connectedToWiFi {
    // Check if we're connected to WiFi
    NSString *WiFiAddress = [self wiFiIPAddress];
    // Check if the string is populated
    if (WiFiAddress == nil || WiFiAddress.length <= 0) {
        // Nothing found
        return false;
    } else {
        // WiFi in use
        return true;
    }
}

- (BOOL)connectedToCellNetwork {
    // Check if we're connected to cell network
    NSString *CellAddress = [self cellIPAddress];
    // Check if the string is populated
    if (CellAddress == nil || CellAddress.length <= 0) {
        // Nothing found
        return false;
    } else {
        // Cellular Network in use
        return true;
    }
}


- (NSString *)carrierName {
    NSString *CarrierName;
    // Get the carrier name
    @try {
        // Get the Telephony Network Info
        CTTelephonyNetworkInfo *TelephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
        // Get the carrier
        CTCarrier *Carrier = [TelephonyInfo subscriberCellularProvider];
        // Get the carrier name
        CarrierName = [Carrier carrierName];
        
        // Check to make sure it's valid
        if (CarrierName == nil || CarrierName.length <= 0) {
            // Return unknown
            CarrierName = nil;
        }
    }
    @catch (NSException *exception) {
        // Error finding the name
        CarrierName = nil;
    }
    return CarrierName;
}

- (NSString *)carrierCountry {
    NSString *CarrierCountry;
    // Get the country that the carrier is located in
    @try {
        // Get the locale
        NSLocale *CurrentCountry = [NSLocale currentLocale];
        // Get the country Code
        CarrierCountry = [CurrentCountry objectForKey:NSLocaleCountryCode];
        // Check if it returned anything
        if (CarrierCountry == nil || CarrierCountry.length <= 0) {
            // No country found
            CarrierCountry = nil;
        }
    }
    @catch (NSException *exception) {
        // Failed, return nil
        CarrierCountry = nil;
    }
    return CarrierCountry;
}

- (NSString *)carrierMobileCountryCode {
    NSString *CarrierMobileCountryCode;
    // Get the carrier mobile country code
    @try {
        // Get the Telephony Network Info
        CTTelephonyNetworkInfo *TelephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
        // Get the carrier
        CTCarrier *Carrier = [TelephonyInfo subscriberCellularProvider];
        // Get the carrier mobile country code
        CarrierMobileCountryCode = [Carrier mobileCountryCode];
        
        // Check to make sure it's valid
        if (CarrierMobileCountryCode == nil || CarrierMobileCountryCode.length <= 0) {
            // Return unknown
            CarrierMobileCountryCode = nil;
        }
    }
    @catch (NSException *exception) {
        // Error finding the name
        CarrierMobileCountryCode = nil;
    }
    return CarrierMobileCountryCode;
}

- (NSString *)carrierISOCountryCode {
    NSString *CarrierISOCountryCode;
    // Get the carrier ISO country code
    @try {
        // Get the Telephony Network Info
        CTTelephonyNetworkInfo *TelephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
        // Get the carrier
        CTCarrier *Carrier = [TelephonyInfo subscriberCellularProvider];
        // Get the carrier ISO country code
        CarrierISOCountryCode = [Carrier isoCountryCode];
        
        // Check to make sure it's valid
        if (CarrierISOCountryCode == nil || CarrierISOCountryCode.length <= 0) {
            // Return unknown
            CarrierISOCountryCode = nil;
        }
    }
    @catch (NSException *exception) {
        // Error finding the name
        CarrierISOCountryCode = nil;
    }
    return CarrierISOCountryCode;
}

- (NSString *)carrierMobileNetworkCode {
    NSString *carrierMobileNetworkCode;
    // Get the carrier mobile network code
    @try {
        // Get the Telephony Network Info
        CTTelephonyNetworkInfo *TelephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
        // Get the carrier
        CTCarrier *Carrier = [TelephonyInfo subscriberCellularProvider];
        // Get the carrier mobile network code
        carrierMobileNetworkCode = [Carrier mobileNetworkCode];
        
        // Check to make sure it's valid
        if (carrierMobileNetworkCode == nil || carrierMobileNetworkCode.length <= 0) {
            // Return unknown
            carrierMobileNetworkCode = nil;
        }
    }
    @catch (NSException *exception) {
        // Error finding the name
        carrierMobileNetworkCode = nil;
    }
    return carrierMobileNetworkCode;
}

- (BOOL)carrierAllowsVOIP {
    BOOL CarrierAllowsVOIP;
    // Check if the carrier allows VOIP
    @try {
        // Get the Telephony Network Info
        CTTelephonyNetworkInfo *TelephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
        // Get the carrier
        CTCarrier *Carrier = [TelephonyInfo subscriberCellularProvider];
        // Get the carrier VOIP Status
        CarrierAllowsVOIP = [Carrier allowsVOIP];
    }
    @catch (NSException *exception) {
        // Error finding the VOIP Status
        CarrierAllowsVOIP = NO;
    }
    return CarrierAllowsVOIP;
}

- (NSString *)diskSpace {
    NSString *DiskSpace;
    // Get the total disk space
    @try {
        // Get the long total disk space
        long long Space = [self longDiskSpace];
        
        // Check to make sure it's valid
        if (Space <= 0) {
            // Error, no disk space found
            DiskSpace = nil;
            return DiskSpace;
        }
        
        // Turn that long long into a string
        DiskSpace = [self formatMemory:Space];
        
        // Check to make sure it's valid
        if (DiskSpace == nil || DiskSpace.length <= 0) {
            // Error, diskspace not given
            DiskSpace = nil;
        }
    }
    @catch (NSException * ex) {
        // Error
        DiskSpace = nil;
    }
    return DiskSpace;
}

- (NSString *)freeDiskSpaceinRaw {
    NSString *FreeDiskSpaceinRaw;
    FreeDiskSpaceinRaw = [self freeDiskSpace:NO];
    return FreeDiskSpaceinRaw;
}

- (NSString *)freeDiskSpaceinPercent {
    NSString *FreeDiskSpaceinPercent;
    FreeDiskSpaceinPercent = [self freeDiskSpace:YES];
    return FreeDiskSpaceinPercent;
}

- (NSString *)usedDiskSpaceinRaw {
    NSString *UsedDiskSpaceinRaw;
    UsedDiskSpaceinRaw = [self usedDiskSpace:NO];
    return UsedDiskSpaceinRaw;
}

- (NSString *)usedDiskSpaceinPercent {
    NSString *UsedDiskSpaceinPercent;
    UsedDiskSpaceinPercent = [self usedDiskSpace:YES];
    return UsedDiskSpaceinPercent;
}

- (long long)longDiskSpace {
    long long LongDiskSpace;
    // Get the long long disk space
    @try {
        // Set up variables
        NSError *Error = nil;
        NSDictionary *FileAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&Error];
        
        // Get the file attributes of the home directory assuming no errors
        if (Error == nil) {
            // Get the size of the filesystem
            LongDiskSpace = [[FileAttributes objectForKey:NSFileSystemSize] longLongValue];
        } else {
            // Error, return nil
            LongDiskSpace = -1;
            return LongDiskSpace;
        }
        
        // Check to make sure it's a valid size
        if (LongDiskSpace <= 0) {
            // Invalid size
            LongDiskSpace = -1;
        }
    }
    @catch (NSException *exception) {
        // Error
        LongDiskSpace = -1;
    }
    return LongDiskSpace;
}

- (long long)longFreeDiskSpace {
    long long LongFreeDiskSpace;
    // Get the long total free disk space
    @try {
        // Set up the variables
        NSError *Error = nil;
        NSDictionary *FileAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&Error];
        
        // Get the file attributes of the home directory assuming no errors
        if (Error == nil) {
            LongFreeDiskSpace = [[FileAttributes objectForKey:NSFileSystemFreeSize] longLongValue];
        } else {
            // There was an error
            LongFreeDiskSpace = -1;
            return LongFreeDiskSpace;
        }
        
        // Check for valid size
        if (LongFreeDiskSpace <= 0) {
            // Invalid size
            LongFreeDiskSpace = -1;
        }
    }
    @catch (NSException *exception) {
        // Error
        LongFreeDiskSpace = -1;
    }
    return LongFreeDiskSpace;
}

- (NSString *)SDWebImageCacheDirectoryPath {
    NSString *SDWebImageCacheDefaultDirectoryPath;
    // Get the SDWebImageCacheDirectory Path
    @try {
        // Create the Path
        SDWebImageCacheDefaultDirectoryPath = [[[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0]
                                                stringByAppendingPathComponent:@"Caches"]
                                               stringByAppendingPathComponent:@"com.hackemist.SDWebImageCache.default"];
        // Validate the Path
        if (SDWebImageCacheDefaultDirectoryPath == nil || SDWebImageCacheDefaultDirectoryPath.length <= 0) {
            // Invalid CacheDirectory Path
            SDWebImageCacheDefaultDirectoryPath = nil;
        }
#pragma  mark 关闭Icloud 云端上传
        [self addSkipBackupAttributeToItemAtURL:[[NSURL alloc]initWithString:SDWebImageCacheDefaultDirectoryPath]];
    }
    @catch (NSException *exception) {
        // Error
        SDWebImageCacheDefaultDirectoryPath = nil;
    }
    return SDWebImageCacheDefaultDirectoryPath;
}

- (NSString *)documentDirectoryPath {
    NSString *DocumentDirectoryPath;
    // Get the DocumentDirectory Path
    @try {
        // Search for the Path
        DocumentDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        // Validate the Path
        if (DocumentDirectoryPath == nil || DocumentDirectoryPath.length <= 0) {
            // Invalid DocumentDirectory Path
            DocumentDirectoryPath = nil;
        }
    }
    @catch (NSException *exception) {
        // Error
        DocumentDirectoryPath = nil;
    }
    
    return DocumentDirectoryPath;
}
#pragma mark 缓存路径
- (NSString *)CachesDirectoryPath {
    NSString *CachesDirectoryPath;
    // Get the DocumentDirectory Path
    @try {
        // Search for the Path
        CachesDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        // Validate the Path
        if (CachesDirectoryPath == nil || CachesDirectoryPath.length <= 0) {
            // Invalid DocumentDirectory Path
            CachesDirectoryPath = nil;
        }
    }
    @catch (NSException *exception) {
        // Error
        CachesDirectoryPath = nil;
    }
    
    return CachesDirectoryPath;
}

//禁止文件路径上传到icloud
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    BOOL success=NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath: [URL path]]) {
        return success;
    }
    NSError *error = nil;
     success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
     if(!success){
          NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
      }else{
//          NSLog(@"成功%@   from  backup%@", [URL path], error);

      }
    return success;
}

- (NSString *)userDirectoryPath {
    NSString *UserDirectoryPath;
    // Get the UserDirectory Path
    @try {
        // Create the Path
        UserDirectoryPath = [[self documentDirectoryPath] stringByAppendingPathComponent:@"Users"];
        // Validate if the UserDirectory Exists at that Path
        if (![[NSFileManager defaultManager] fileExistsAtPath:UserDirectoryPath]) {
            // Inexistence, Create the UserDirectory
            NSError *createUserDirectoryError = nil;
            if (![[NSFileManager defaultManager] createDirectoryAtPath:UserDirectoryPath withIntermediateDirectories:YES attributes:nil error:&createUserDirectoryError]) {
                // Create the UserDirectory Failure
                CMTLogError(@"createUserDirectoryError :%@", createUserDirectoryError);
                UserDirectoryPath = nil;
            }
           #pragma  mark 关闭Icloud 云端上传
            [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:UserDirectoryPath]];
        }
        // Validate the Path
        if (UserDirectoryPath == nil || UserDirectoryPath.length <= 0) {
            // Invalid UserDirectory Path
            UserDirectoryPath = nil;
        }
    }
    @catch (NSException *exception) {
        // Error
        UserDirectoryPath = nil;
    }
    return UserDirectoryPath;
}

- (NSString *)userFilePath {
    NSString *UserFilePath;
    // Get the User File Path
    @try {
        // Create the Path
        UserFilePath = [[self userDirectoryPath] stringByAppendingPathComponent:@"DefaultUser"];
        // Validate the Path
        if (UserFilePath == nil || UserFilePath.length <= 0) {
            // Invalid User File Path
            UserFilePath = nil;
        }
    }
    @catch (NSException *exception) {
        // Error
        UserFilePath = nil;
    }
    return UserFilePath;
}

- (NSString *)collectionListFilePath {
    NSString *CollectionListFilePath;
    // Get the collectionList File Path
    @try {
        // Create the Path
        CollectionListFilePath = [[self userDirectoryPath] stringByAppendingPathComponent:@"collectionList"];
        // Validate the Path
        if (CollectionListFilePath == nil || CollectionListFilePath.length <= 0) {
            // Invalid collectionList File Path
            CollectionListFilePath = nil;
        }
    }
    @catch (NSException *exception) {
        // Error
        CollectionListFilePath = nil;
    }
    return CollectionListFilePath;
}
- (NSString *)downLoadDiectoryPath {
    NSString *AddPostDiectoryPath;
    // Get the AddPostDiectory Path
    @try {
        // Create the Path
        AddPostDiectoryPath = [[self documentDirectoryPath] stringByAppendingPathComponent:@"down"];
        // Validate if the AddPostDiectory Exists at that Path
        if (![[NSFileManager defaultManager] fileExistsAtPath:AddPostDiectoryPath]) {
            // Inexistence, Create the AddPostDiectory
            NSError *createAddPostDiectoryError = nil;
            if (![[NSFileManager defaultManager] createDirectoryAtPath:AddPostDiectoryPath withIntermediateDirectories:YES attributes:nil error:&createAddPostDiectoryError]) {
                // Create the AddPostDiectory Failure
                CMTLogError(@"createAddPostDiectoryError :%@", createAddPostDiectoryError);
                AddPostDiectoryPath = nil;
            }
        }
        // Validate the Path
        if (AddPostDiectoryPath == nil || AddPostDiectoryPath.length <= 0) {
            // Invalid UserDirectory Path
            AddPostDiectoryPath = nil;
        }
         [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:AddPostDiectoryPath]];
    }
    @catch (NSException *exception) {
        // Error
        AddPostDiectoryPath = nil;
    }
    return AddPostDiectoryPath;
}

- (NSString *)addPostDiectoryPath {
    NSString *AddPostDiectoryPath;
    // Get the AddPostDiectory Path
    @try {
        // Create the Path
        AddPostDiectoryPath = [[self userDirectoryPath] stringByAppendingPathComponent:@"AddPost"];
        // Validate if the AddPostDiectory Exists at that Path
        if (![[NSFileManager defaultManager] fileExistsAtPath:AddPostDiectoryPath]) {
            // Inexistence, Create the AddPostDiectory
            NSError *createAddPostDiectoryError = nil;
            if (![[NSFileManager defaultManager] createDirectoryAtPath:AddPostDiectoryPath withIntermediateDirectories:YES attributes:nil error:&createAddPostDiectoryError]) {
                // Create the AddPostDiectory Failure
                CMTLogError(@"createAddPostDiectoryError :%@", createAddPostDiectoryError);
                AddPostDiectoryPath = nil;
            }
        }
        // Validate the Path
        if (AddPostDiectoryPath == nil || AddPostDiectoryPath.length <= 0) {
            // Invalid UserDirectory Path
            AddPostDiectoryPath = nil;
        }
    }
    @catch (NSException *exception) {
        // Error
        AddPostDiectoryPath = nil;
    }
    return AddPostDiectoryPath;
}

- (NSString *)addPostFilePath {
    NSString *AddPostFilePath;
    // Get the AddPost File Path
    @try {
        // Create the Path
        AddPostFilePath = [[self addPostDiectoryPath] stringByAppendingPathComponent:@"AddPost"];
        // Validate the Path
        if (AddPostFilePath == nil || AddPostFilePath.length <= 0) {
            // Invalid User File Path
            AddPostFilePath = nil;
        }
    }
    @catch (NSException *exception) {
        // Error
        AddPostFilePath = nil;
    }
    return AddPostFilePath;
}

- (NSString *)addGroupPostFilePath {
    NSString *AddGroupPostFilePath;
    // Get the AddGroupPost File Path
    @try {
        // Create the Path
        AddGroupPostFilePath = [[self addPostDiectoryPath] stringByAppendingPathComponent:@"AddGroupPost"];
        // Validate the Path
        if (AddGroupPostFilePath == nil || AddGroupPostFilePath.length <= 0) {
            // Invalid User File Path
            AddGroupPostFilePath = nil;
        }
    }
    @catch (NSException *exception) {
        // Error
        AddGroupPostFilePath = nil;
    }
    return AddGroupPostFilePath;
}

- (NSString *)addPostAdditionalFilePath {
    NSString *AddPostAdditionalFilePath;
    // Get the AddPostAdditional File Path
    @try {
        // Create the Path
        AddPostAdditionalFilePath = [[self addPostDiectoryPath] stringByAppendingPathComponent:@"AddPostAdditional"];
        // Validate the Path
        if (AddPostAdditionalFilePath == nil || AddPostAdditionalFilePath.length <= 0) {
            // Invalid User File Path
            AddPostAdditionalFilePath = nil;
        }
    }
    @catch (NSException *exception) {
        // Error
        AddPostAdditionalFilePath = nil;
    }
     #pragma  mark 关闭Icloud 云端上传
    [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:AddPostAdditionalFilePath]];

    return AddPostAdditionalFilePath;
}
- (NSString *)addLiveMeaasgeFilePath {
    NSString *addLiveMeaasgeFilePath;
    // Get the AddPostAdditional File Path
    @try {
        // Create the Path
        addLiveMeaasgeFilePath = [[self addPostDiectoryPath] stringByAppendingPathComponent:@"addLiveMeaasgeFilePath"];
        // Validate the Path
        if (addLiveMeaasgeFilePath == nil || addLiveMeaasgeFilePath.length <= 0) {
            // Invalid User File Path
            addLiveMeaasgeFilePath = nil;
        }
    }
    @catch (NSException *exception) {
        // Error
        addLiveMeaasgeFilePath = nil;
    }
    #pragma  mark 关闭Icloud 云端上传
    [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:addLiveMeaasgeFilePath]];
    return addLiveMeaasgeFilePath;
}


- (NSString *)subscriptionDiectoryPath {
    NSString *SubscriptionDiectoryPath;
    // Get the SubscriptionDiectory Path
    @try {
        // Create the Path
        SubscriptionDiectoryPath = [[self documentDirectoryPath] stringByAppendingPathComponent:@"Subscription"];
        // Validate if the SubscriptionDiectory Exists at that Path
        if (![[NSFileManager defaultManager] fileExistsAtPath:SubscriptionDiectoryPath]) {
            // Inexistence, Create the SubscriptionDiectory
            NSError *createSubscriptionDiectoryError = nil;
            if (![[NSFileManager defaultManager] createDirectoryAtPath:SubscriptionDiectoryPath withIntermediateDirectories:YES attributes:nil error:&createSubscriptionDiectoryError]) {
                // Create the SubscriptionDiectory Failure
                CMTLogError(@"createSubscriptionDiectoryError :%@", createSubscriptionDiectoryError);
                SubscriptionDiectoryPath = nil;
            }
        }
        // Validate the Path
        if (SubscriptionDiectoryPath == nil || SubscriptionDiectoryPath.length <= 0) {
            // Invalid SubscriptionDiectory Path
            SubscriptionDiectoryPath = nil;
        }
       #pragma  mark 关闭Icloud 云端上传
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:SubscriptionDiectoryPath]];
        
    }
    @catch (NSException *exception) {
        // Error
        SubscriptionDiectoryPath = nil;
    }
    return SubscriptionDiectoryPath;
}

- (NSString *)totalSubscriptionPath {
    NSString *TotalSubscriptionPath;
    // Get the TotalSubscription File Path
    @try {
        // Create the Path
        TotalSubscriptionPath = [[self subscriptionDiectoryPath] stringByAppendingPathComponent:@"TotalSubscription"];
        // Validate the Path
        if (TotalSubscriptionPath == nil || TotalSubscriptionPath.length <= 0) {
            // Invalid User File Path
            TotalSubscriptionPath = nil;
        }
    }
    @catch (NSException *exception) {
        // Error
        TotalSubscriptionPath = nil;
    }
#pragma  mark 关闭Icloud 云端上传
    [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:TotalSubscriptionPath]];
    return TotalSubscriptionPath;
}

- (NSString *)allHosptialsDiectory
{
    NSString *AllHosptialsDiectory;
    @try {
        AllHosptialsDiectory = [[self documentDirectoryPath] stringByAppendingPathComponent:@"AllHosptials"];
        if (![[NSFileManager defaultManager]fileExistsAtPath:AllHosptialsDiectory])
        {
            NSError *creatAllHosptialsDiectory = nil;
            if(![[NSFileManager defaultManager]createDirectoryAtPath:AllHosptialsDiectory withIntermediateDirectories:YES attributes:nil error:&creatAllHosptialsDiectory])
            {
                CMTLogError(@"createAllHosptialsDirectoryError:%@",creatAllHosptialsDiectory);
            }

        }
        
        if (AllHosptialsDiectory == nil || AllHosptialsDiectory.length <= 0) {
            // Invalid UserDirectory Path
            AllHosptialsDiectory = nil;
        }
#pragma  mark 关闭Icloud 云端上传
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:AllHosptialsDiectory]];
    }
    @catch (NSException *exception) {
        AllHosptialsDiectory = nil;
    }
    return AllHosptialsDiectory;
}


- (NSString *)allareasDiectory
{
    NSString *allareasDiectory;
    @try {
        allareasDiectory = [[self documentDirectoryPath] stringByAppendingPathComponent:@"AllAreas"];
        if (![[NSFileManager defaultManager]fileExistsAtPath:allareasDiectory])
        {
            NSError *creatAllAreasDiectory = nil;
            if(![[NSFileManager defaultManager]createDirectoryAtPath:allareasDiectory withIntermediateDirectories:YES attributes:nil error:&creatAllAreasDiectory])
            {
                CMTLogError(@"createAllHosptialsDirectoryError:%@",creatAllAreasDiectory);
            }
            
        }
        
        if (allareasDiectory == nil || allareasDiectory.length <= 0) {
            // Invalid UserDirectory Path
            allareasDiectory = nil;
        }
#pragma  mark 关闭Icloud 云端上传
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:allareasDiectory]];
    }
    @catch (NSException *exception) {
        allareasDiectory = nil;
    }
    return allareasDiectory;
}

- (NSString *)PDFDirectoryPath {
    NSString *PDFDirectoryPath;
    // Get the PDFCacheDirectory Path
    @try {
        // Create the Path
        PDFDirectoryPath = [[self documentDirectoryPath] stringByAppendingPathComponent:@"PDF"];
        // Validate if the CacheDirectory Exists at that Path
        if (![[NSFileManager defaultManager] fileExistsAtPath:PDFDirectoryPath]) {
            // Inexistence, Create the CacheDirectory
            NSError *createDirectoryError = nil;
            if (![[NSFileManager defaultManager] createDirectoryAtPath:PDFDirectoryPath withIntermediateDirectories:YES attributes:nil error:&createDirectoryError]) {
                // Create the CacheDirectory Failure
                CMTLogError(@"createCacheDirectoryError :%@", createDirectoryError);
                PDFDirectoryPath = nil;
            }
        }
        // Validate the Path
        if (PDFDirectoryPath == nil || PDFDirectoryPath.length <= 0) {
            // Invalid CacheDirectory Path
            PDFDirectoryPath = nil;
        }
#pragma  mark 关闭Icloud 云端上传
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:PDFDirectoryPath]];
    }
    @catch (NSException *exception) {
        // Error
        PDFDirectoryPath = nil;
    }
    return PDFDirectoryPath;
}

- (NSString *)cacheDirectoryPath {
    NSString *CacheDirectoryPath;
    // Get the CacheDirectory Path
    @try {
        // Create the Path
        CacheDirectoryPath = [[self documentDirectoryPath] stringByAppendingPathComponent:@"Caches"];
        // Validate if the CacheDirectory Exists at that Path
        if (![[NSFileManager defaultManager] fileExistsAtPath:CacheDirectoryPath]) {
            // Inexistence, Create the CacheDirectory
            NSError *createCacheDirectoryError = nil;
            if (![[NSFileManager defaultManager] createDirectoryAtPath:CacheDirectoryPath withIntermediateDirectories:YES attributes:nil error:&createCacheDirectoryError]) {
                // Create the CacheDirectory Failure
                CMTLogError(@"createCacheDirectoryError :%@", createCacheDirectoryError);
                CacheDirectoryPath = nil;
            }
        }
        // Validate the Path
        if (CacheDirectoryPath == nil || CacheDirectoryPath.length <= 0) {
            // Invalid CacheDirectory Path
            CacheDirectoryPath = nil;
        }
#pragma  mark 关闭Icloud 云端上传
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:CacheDirectoryPath]];

        
    }
    @catch (NSException *exception) {
        // Error
        CacheDirectoryPath = nil;
    }
    return CacheDirectoryPath;
}

- (NSString *)imageCacheDirectoryPath {
    NSString *ImageCacheDirectoryPath;
    // Get the ImageCacheDirectory Path
    @try {
        // Create the Path
        ImageCacheDirectoryPath = [[self cacheDirectoryPath] stringByAppendingPathComponent:@"Images"];
        // Validate if the CacheDirectory Exists at that Path
        if (![[NSFileManager defaultManager] fileExistsAtPath:ImageCacheDirectoryPath]) {
            // Inexistence, Create the CacheDirectory
            NSError *createCacheDirectoryError = nil;
            if (![[NSFileManager defaultManager] createDirectoryAtPath:ImageCacheDirectoryPath withIntermediateDirectories:YES attributes:nil error:&createCacheDirectoryError]) {
                // Create the CacheDirectory Failure
                CMTLogError(@"createCacheDirectoryError :%@", createCacheDirectoryError);
                ImageCacheDirectoryPath = nil;
            }
        }
        // Validate the Path
        if (ImageCacheDirectoryPath == nil || ImageCacheDirectoryPath.length <= 0) {
            // Invalid CacheDirectory Path
            ImageCacheDirectoryPath = nil;
        }
#pragma  mark 关闭Icloud 云端上传
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:ImageCacheDirectoryPath]];
    }
    @catch (NSException *exception) {
        // Error
        ImageCacheDirectoryPath = nil;
    }
    return ImageCacheDirectoryPath;
}

- (NSString *)searchCacheDirectoryPath {
    NSString *searchCacheDirectoryPath;
    // Get the CacheDirectory Path
    @try {
        // Create the Path
        searchCacheDirectoryPath = [[self cacheDirectoryPath] stringByAppendingPathComponent:@"Search"];
        // Validate if the CacheDirectory Exists at that Path
        if (![[NSFileManager defaultManager] fileExistsAtPath:searchCacheDirectoryPath]) {
            // Inexistence, Create the CacheDirectory
            NSError *createCacheDirectoryError = nil;
            if (![[NSFileManager defaultManager] createDirectoryAtPath:searchCacheDirectoryPath withIntermediateDirectories:YES attributes:nil error:&createCacheDirectoryError]) {
                // Create the CacheDirectory Failure
                CMTLogError(@"createCacheDirectoryError :%@", createCacheDirectoryError);
                searchCacheDirectoryPath = nil;
            }
        }
        // Validate the Path
        if (searchCacheDirectoryPath == nil || searchCacheDirectoryPath.length <= 0) {
            // Invalid CacheDirectory Path
            searchCacheDirectoryPath = nil;
        }
#pragma  mark 关闭Icloud 云端上传
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:searchCacheDirectoryPath]];

    }
    @catch (NSException *exception) {
        // Error
        searchCacheDirectoryPath = nil;
    }
    return searchCacheDirectoryPath;
}



- (NSString *)postCacheDirectoryPath {
    NSString *PostCacheDirectoryPath;
    // Get the PostCacheDirectory Path
    @try {
        // Create the Path
        PostCacheDirectoryPath = [[self cacheDirectoryPath] stringByAppendingPathComponent:@"Posts"];
        // Validate if the PostCacheDirectory Exists at that Path
        if (![[NSFileManager defaultManager] fileExistsAtPath:PostCacheDirectoryPath]) {
            // Inexistence, Create the PostCacheDirectory
            NSError *createCacheDirectoryError = nil;
            if (![[NSFileManager defaultManager] createDirectoryAtPath:PostCacheDirectoryPath withIntermediateDirectories:YES attributes:nil error:&createCacheDirectoryError]) {
                // Create the PostCacheDirectory Failure
                CMTLogError(@"createPostCacheDirectoryError :%@", createCacheDirectoryError);
                PostCacheDirectoryPath = nil;
            }
        }
        // Validate the Path
        if (PostCacheDirectoryPath == nil || PostCacheDirectoryPath.length <= 0) {
            // Invalid PostCacheDirectory Path
            PostCacheDirectoryPath = nil;
        }
#pragma  mark 关闭Icloud 云端上传
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:PostCacheDirectoryPath]];
    }
    @catch (NSException *exception) {
        // Error
        PostCacheDirectoryPath = nil;
    }
    return PostCacheDirectoryPath;
}
//创建病例缓存文件夹 add by guoyuanchao
- (NSString *)CaseCacheDirectoryPath {
    NSString *CaseCacheDirectoryPath;
    // Get the PostCacheDirectory Path
    @try {
        // Create the Path
        CaseCacheDirectoryPath = [[self cacheDirectoryPath] stringByAppendingPathComponent:@"Case"];
        // Validate if the PostCacheDirectory Exists at that Path
        if (![[NSFileManager defaultManager] fileExistsAtPath:CaseCacheDirectoryPath]) {
            // Inexistence, Create the PostCacheDirectory
            NSError *createCacheDirectoryError = nil;
            if (![[NSFileManager defaultManager] createDirectoryAtPath:CaseCacheDirectoryPath withIntermediateDirectories:YES attributes:nil error:&createCacheDirectoryError]) {
                // Create the PostCacheDirectory Failure
                CMTLogError(@"createPostCacheDirectoryError :%@", createCacheDirectoryError);
                CaseCacheDirectoryPath = nil;
            }
        }
        // Validate the Path
        if (CaseCacheDirectoryPath == nil || CaseCacheDirectoryPath.length <= 0) {
            // Invalid PostCacheDirectory Path
            CaseCacheDirectoryPath = nil;
        }
#pragma  mark 关闭Icloud 云端上传
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:CaseCacheDirectoryPath]];

    }
    @catch (NSException *exception) {
        // Error
        CaseCacheDirectoryPath = nil;
    }
    return CaseCacheDirectoryPath;
}

//创建疾病列表缓存文件夹 add by guoyuanchao
- (NSString *)DiseaseCacheDirectoryPath {
    NSString *DiseaseCacheDirectoryPath;
    // Get the PostCacheDirectory Path
    @try {
        // Create the Path
        DiseaseCacheDirectoryPath = [[self cacheDirectoryPath] stringByAppendingPathComponent:@"Disease"];
        // Validate if the PostCacheDirectory Exists at that Path
        if (![[NSFileManager defaultManager] fileExistsAtPath:DiseaseCacheDirectoryPath]) {
            // Inexistence, Create the PostCacheDirectory
            NSError *createCacheDirectoryError = nil;
            if (![[NSFileManager defaultManager] createDirectoryAtPath:DiseaseCacheDirectoryPath withIntermediateDirectories:YES attributes:nil error:&createCacheDirectoryError]) {
                // Create the PostCacheDirectory Failure
                CMTLogError(@"createPostCacheDirectoryError :%@", createCacheDirectoryError);
                DiseaseCacheDirectoryPath = nil;
            }
        }
        // Validate the Path
        if (DiseaseCacheDirectoryPath == nil || DiseaseCacheDirectoryPath.length <= 0) {
            // Invalid PostCacheDirectory Path
            DiseaseCacheDirectoryPath = nil;
        }
#pragma  mark 关闭Icloud 云端上传
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DiseaseCacheDirectoryPath]];
    }
    @catch (NSException *exception) {
        // Error
        DiseaseCacheDirectoryPath = nil;
    }
    return DiseaseCacheDirectoryPath;
}

// 创建小组缓存文件夹
- (NSString *)CreatGroupDirectoryPath{
    NSString *CreatGroupDirectoryPath;
    // Get the PostCacheDirectory Path
    @try {
        // Create the Path
        CreatGroupDirectoryPath = [[self cacheDirectoryPath] stringByAppendingPathComponent:@"creatGroup"];
        // Validate if the PostCacheDirectory Exists at that Path
        if (![[NSFileManager defaultManager] fileExistsAtPath:CreatGroupDirectoryPath]) {
            // Inexistence, Create the PostCacheDirectory
            NSError *CreatGroupDirectoryError = nil;
            if (![[NSFileManager defaultManager] createDirectoryAtPath:CreatGroupDirectoryPath withIntermediateDirectories:YES attributes:nil error:&CreatGroupDirectoryError]) {
                // Create the PostCacheDirectory Failure
                CMTLogError(@"CreatGroupDirectoryError :%@", CreatGroupDirectoryError);
                CreatGroupDirectoryPath = nil;
            }
        }
        // Validate the Path
        if (CreatGroupDirectoryPath == nil || CreatGroupDirectoryPath.length <= 0) {
            // Invalid PostCacheDirectory Path
            CreatGroupDirectoryPath = nil;
        }
#pragma  mark 关闭Icloud 云端上传
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:CreatGroupDirectoryPath]];

    }
    @catch (NSException *exception) {
        // Error
        CreatGroupDirectoryPath = nil;
    }
    return CreatGroupDirectoryPath;
}

- (NSString *)focusListFilePath {
    NSString *FocusListFilePath;
    // Get the focusList File Path
    @try {
        // Create the Path
        FocusListFilePath = [[self postCacheDirectoryPath] stringByAppendingPathComponent:@"FocusList"];
        // Validate the Path
        if (FocusListFilePath == nil || FocusListFilePath.length <= 0) {
            // Invalid focusList File Path
            FocusListFilePath = nil;
        }
#pragma  mark 关闭Icloud 云端上传
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:FocusListFilePath]];
    }
    @catch (NSException *exception) {
        // Error
        FocusListFilePath = nil;
    }
    return FocusListFilePath;
}
- (NSString *)LiveListFilePath {
    NSString *LiveListFilePath;
    // Get the focusList File Path
    @try {
        // Create the Path
        LiveListFilePath = [[self postCacheDirectoryPath] stringByAppendingPathComponent:@"LiveList"];
        // Validate the Path
        if (LiveListFilePath == nil || LiveListFilePath.length <= 0) {
            // Invalid focusList File Path
            LiveListFilePath = nil;
        }
#pragma  mark 关闭Icloud 云端上传
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:LiveListFilePath]];
    }
    @catch (NSException *exception) {
        // Error
        LiveListFilePath = nil;
    }
    return LiveListFilePath;
}


- (NSString *)postListFilePath {
    NSString *PostListFilePath;
    // Get the postList File Path
    @try {
        // Create the Path
        PostListFilePath = [[self postCacheDirectoryPath] stringByAppendingPathComponent:@"PostList"];
        // Validate the Path
        if (PostListFilePath == nil || PostListFilePath.length <= 0) {
            // Invalid postList File Path
            PostListFilePath = nil;
        }
#pragma  mark 关闭Icloud 云端上传
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:PostListFilePath]];
    }
    @catch (NSException *exception) {
        // Error
        PostListFilePath = nil;
    }
    return PostListFilePath;
}
//增加病例缓存路径 guoyuanchao
- (NSString *)caseListFilePath {
    NSString *caseListFilePath;
    // Get the postList File Path
    @try {
        // Create the Path
        caseListFilePath = [[self CaseCacheDirectoryPath] stringByAppendingPathComponent:@"CaseList"];
        // Validate the Path
        if (caseListFilePath == nil || caseListFilePath.length <= 0) {
            // Invalid postList File Path
            caseListFilePath = nil;
        }
#pragma  mark 关闭Icloud 云端上传
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:caseListFilePath]];
    }
    @catch (NSException *exception) {
        // Error
        caseListFilePath = nil;
    }
    return caseListFilePath;
}
//增加病例全部小组缓存路径 guoyuanchao
- (NSString *)caseAllTeamFilePath {
    NSString *caseAllTeamFilePath;
    // Get the postList File Path
    @try {
        // Create the Path
        caseAllTeamFilePath = [[self CaseCacheDirectoryPath] stringByAppendingPathComponent:@"CaseTeamList"];
        // Validate the Path
        if (caseAllTeamFilePath == nil || caseAllTeamFilePath.length <= 0) {
            // Invalid postList File Path
            caseAllTeamFilePath = nil;
        }
#pragma  mark 关闭Icloud 云端上传
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:caseAllTeamFilePath]];
    }
    @catch (NSException *exception) {
        // Error
        caseAllTeamFilePath = nil;
    }
    return caseAllTeamFilePath;
}
//增加病例小组详情缓存路径 guoyuanchao
- (NSString *)caseTeamFilePath {
    NSString *caseTeamFilePath;
    // Get the postList File Path
    @try {
        // Create the Path
        caseTeamFilePath = [[self CaseCacheDirectoryPath] stringByAppendingPathComponent:@"CaseTeamdata"];
        // Validate the Path
        if (caseTeamFilePath == nil || caseTeamFilePath.length <= 0) {
            // Invalid postList File Path
            caseTeamFilePath = nil;
        }
#pragma  mark 关闭Icloud 云端上传
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:caseTeamFilePath]];
    }
    @catch (NSException *exception) {
        // Error
        caseTeamFilePath = nil;
    }
    return caseTeamFilePath;
}
//增加我加入的病例小组缓存路径 guoyuanchao
- (NSString *)caseMyTeamFilePath {
    NSString *caseMyTeamFilePath;
    // Get the postList File Path
    @try {
        // Create the Path
        caseMyTeamFilePath = [[self CaseCacheDirectoryPath] stringByAppendingPathComponent:@"CaseMyTeamdata"];
        // Validate the Path
        if (caseMyTeamFilePath == nil || caseMyTeamFilePath.length <= 0) {
            // Invalid postList File Path
            caseMyTeamFilePath = nil;
        }
#pragma  mark 关闭Icloud 云端上传
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:caseMyTeamFilePath]];
    }
    @catch (NSException *exception) {
        // Error
        caseMyTeamFilePath = nil;
    }
    return caseMyTeamFilePath;
}

// 创建小组 小组选择类型缓存路径 ZH

- (NSString *)groupTypeChoicePath {
    NSString *groupTypeChoicePath;
    // Get the postList File Path
    @try {
        // Create the Path
        groupTypeChoicePath = [[self CreatGroupDirectoryPath] stringByAppendingPathComponent:@"groupTypeChoice"];
        // Validate the Path
        if (groupTypeChoicePath == nil || groupTypeChoicePath.length <= 0) {
            // Invalid postList File Path
            groupTypeChoicePath = nil;
        }
     # pragma  mark 关闭Icloud 云端上传
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:groupTypeChoicePath]];
    }
    @catch (NSException *exception) {
        // Error
        groupTypeChoicePath = nil;
    }
    return groupTypeChoicePath;
}


- (NSString *)themeCacheDirectoryPath {
    NSString *ThemeCacheDirectoryPath;
    // Get the ThemeCacheDirectory Path
    @try {
        // Create the Path
        ThemeCacheDirectoryPath = [[self cacheDirectoryPath] stringByAppendingPathComponent:@"Themes"];
        // Validate if the ThemeCacheDirectory Exists at that Path
        if (![[NSFileManager defaultManager] fileExistsAtPath:ThemeCacheDirectoryPath]) {
            // Inexistence, Create the ThemeCacheDirectory
            NSError *createCacheDirectoryError = nil;
            if (![[NSFileManager defaultManager] createDirectoryAtPath:ThemeCacheDirectoryPath withIntermediateDirectories:YES attributes:nil error:&createCacheDirectoryError]) {
                // Create the ThemeCacheDirectory Failure
                CMTLogError(@"createThemeCacheDirectoryError :%@", createCacheDirectoryError);
                ThemeCacheDirectoryPath = nil;
            }
        }
        // Validate the Path
        if (ThemeCacheDirectoryPath == nil || ThemeCacheDirectoryPath.length <= 0) {
            // Invalid ThemeCacheDirectory Path
            ThemeCacheDirectoryPath = nil;
        }
# pragma  mark 关闭Icloud 云端上传
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:ThemeCacheDirectoryPath]];
    }
    @catch (NSException *exception) {
        // Error
        ThemeCacheDirectoryPath = nil;
    }
    return ThemeCacheDirectoryPath;
}
//增加疾病缓存 add by guoyuanchao
- (NSString *)diseaseListCacheFilePath {
    NSString *diseaseListFilePath;
    // Get the postList File Path
    @try {
        // Create the Path
        diseaseListFilePath = [[self DiseaseCacheDirectoryPath] stringByAppendingPathComponent:@"DiseaseList"];
        // Validate the Path
        if (diseaseListFilePath == nil || diseaseListFilePath.length <= 0) {
            // Invalid postList File Path
            diseaseListFilePath = nil;
        }
    }
    @catch (NSException *exception) {
        // Error
        diseaseListFilePath = nil;
    }
    return diseaseListFilePath;
}


- (NSString *)hosptialCacheDirectoryPath {
    NSString *hosptialCacheDirectoryPath;
    @try {
        hosptialCacheDirectoryPath = [[self cacheDirectoryPath]stringByAppendingPathComponent:@"Hosptial"];
        if (![[NSFileManager defaultManager]fileExistsAtPath:hosptialCacheDirectoryPath])
        {
            NSError *createCacheDirectory = nil;
            if (![[NSFileManager defaultManager]createDirectoryAtPath:hosptialCacheDirectoryPath withIntermediateDirectories:YES attributes:nil error:&createCacheDirectory])
            {
                CMTLogError(@"createCacheHosptialDirectoryError=%@",createCacheDirectory);
                hosptialCacheDirectoryPath = nil;
            }
            if (hosptialCacheDirectoryPath == nil||hosptialCacheDirectoryPath.length<= 0)
            {
                hosptialCacheDirectoryPath = nil;
            }
        }
# pragma  mark 关闭Icloud 云端上传
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:hosptialCacheDirectoryPath]];
    }
    @catch (NSException *exception) {
        hosptialCacheDirectoryPath = nil;
    }
    return hosptialCacheDirectoryPath;
}

- (NSString *)cityCode {
    static NSString *CityCode;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Get the user's CityCode
        @try {
            // Get the location

            // Get the cityCode from the location
            CityCode = @"110000";
            // Check for validity
            if (CityCode == nil || CityCode.length <= 0) {
                // Error, invalid cityCode
                CityCode = nil;
            }
        }
        @catch (NSException *exception) {
            // Error
            CityCode = nil;
        }
    });
    return CityCode;
}

- (NSString *)country {
    static NSString *Country;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Get the user's country
        @try {
            // Get the locale
            NSLocale *Locale = [NSLocale currentLocale];
            // Get the country from the locale
            Country = [Locale localeIdentifier];
            // Check for validity
            if (Country == nil || Country.length <= 0) {
                // Error, invalid country
                Country = nil;
            }
        }
        @catch (NSException *exception) {
            // Error
            Country = nil;
        }
    });
    return Country;
}

- (NSString *)language {
    static NSString *Language;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Get the user's language
        @try {
            // Get the list of languages
            NSArray *LanguageArray = [NSLocale preferredLanguages];
            // Get the user's language
            Language = [LanguageArray objectAtIndex:0];
            // Check for validity
            if (Language == nil || Language.length <= 0) {
                // Error, invalid language
                Language = nil;
            }
        }
        @catch (NSException *exception) {
            // Error
            Language = nil;
        }
    });
    return Language;
}

- (NSString *)timeZoneSS {
    static NSString *TimeZoneSS;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Get the user's timezone
        @try {
            // Get the system timezone
            NSTimeZone *LocalTime = [NSTimeZone systemTimeZone];
            // Convert the time zone to a string
            TimeZoneSS = [LocalTime name];
            // Check for validity
            if (TimeZoneSS == nil || TimeZoneSS.length <= 0) {
                // Error, invalid TimeZone
                TimeZoneSS = nil;
            }
        }
        @catch (NSException *exception) {
            // Error
            TimeZoneSS = nil;
        }
    });
    return TimeZoneSS;
}

- (NSString *)currency {
    static NSString *Currency;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Get the user's currency
        @try {
            // Get the system currency
            Currency = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
            // Check for validity
            if (Currency == nil || Currency.length <= 0) {
                // Error, invalid Currency
                Currency = nil;
            }
        }
        @catch (NSException *exception) {
            // Error
            Currency = nil;
        }
    });
    return Currency;
}

#pragma mark Private Method
// System Device Type (iPhone1,0) (Formatted = iPhone 1)
- (NSString *)systemDeviceTypeOfFormatted:(BOOL)formatted {
    // Set up a Device Type String
    NSString *DeviceType;
    
    // Check if it should be formatted
    if (formatted) {
        // Formatted
        @try {
            // Set up a new Device Type String
            NSString *NewDeviceType;
            // Set up a struct
            struct utsname DT;
            // Get the system information
            uname(&DT);
            // Set the device type to the machine type
            DeviceType = [NSString stringWithFormat:@"%s", DT.machine];
            
            if ([DeviceType isEqualToString:@"i386"])
                NewDeviceType = @"iPhone Simulator";
            else if ([DeviceType isEqualToString:@"x86_64"])
                NewDeviceType = @"iPhone Simulator";
            else if ([DeviceType isEqualToString:@"iPhone1,1"])
                NewDeviceType = @"iPhone";
            else if ([DeviceType isEqualToString:@"iPhone1,2"])
                NewDeviceType = @"iPhone 3G";
            else if ([DeviceType isEqualToString:@"iPhone2,1"])
                NewDeviceType = @"iPhone 3GS";
            else if ([DeviceType isEqualToString:@"iPhone3,1"])
                NewDeviceType = @"iPhone 4";
            else if ([DeviceType isEqualToString:@"iPhone4,1"])
                NewDeviceType = @"iPhone 4S";
            else if ([DeviceType isEqualToString:@"iPhone5,1"])
                NewDeviceType = @"iPhone 5(GSM)";
            else if ([DeviceType isEqualToString:@"iPhone5,2"])
                NewDeviceType = @"iPhone 5(GSM+CDMA)";
            else if ([DeviceType isEqualToString:@"iPhone5,3"])
                NewDeviceType = @"iPhone 5c(GSM)";
            else if ([DeviceType isEqualToString:@"iPhone5,4"])
                NewDeviceType = @"iPhone 5c(GSM+CDMA)";
            else if ([DeviceType isEqualToString:@"iPhone6,1"])
                NewDeviceType = @"iPhone 5s(GSM)";
            else if ([DeviceType isEqualToString:@"iPhone6,2"])
                NewDeviceType = @"iPhone 5s(GSM+CDMA)";
            else if ([DeviceType isEqualToString:@"iPhone7,1"])
                NewDeviceType = @"iPhone 6 Plus";
            else if ([DeviceType isEqualToString:@"iPhone7,2"])
                NewDeviceType = @"iPhone 6";
            else if ([DeviceType isEqualToString:@"iPhone8,1"])
                NewDeviceType = @"iPhone 6s";
            else if ([DeviceType isEqualToString:@"iPhone8,2"])
                NewDeviceType = @"iPhone 6sPlus";
            else if ([DeviceType isEqualToString:@"iPhone8,4"])
                NewDeviceType = @"iPhone SE";
            else if ([DeviceType isEqualToString:@"iPhone9,1"]||[DeviceType isEqualToString:@"iPhone9,3"])
                NewDeviceType = @"iPhone 7";
            else if ([DeviceType isEqualToString:@"iPhone9,2"]||[DeviceType isEqualToString:@"iPhone9,4"])
                NewDeviceType = @"iPhone 7Plus";
            else if ([DeviceType isEqualToString:@"iPod1,1"])
                NewDeviceType = @"iPod Touch 1G";
            else if ([DeviceType isEqualToString:@"iPod2,1"])
                NewDeviceType = @"iPod Touch 2G";
            else if ([DeviceType isEqualToString:@"iPod3,1"])
                NewDeviceType = @"iPod Touch 3G";
            else if ([DeviceType isEqualToString:@"iPod4,1"])
                NewDeviceType = @"iPod Touch 4G";
            else if ([DeviceType isEqualToString:@"iPod5,1"])
                NewDeviceType = @"iPod Touch 5G";
            else if ([DeviceType isEqualToString:@"iPad1,1"])
                NewDeviceType = @"iPad";
            else if ([DeviceType isEqualToString:@"iPad2,1"])
                NewDeviceType = @"iPad 2(WiFi)";
            else if ([DeviceType isEqualToString:@"iPad2,2"])
                NewDeviceType = @"iPad 2(GSM)";
            else if ([DeviceType isEqualToString:@"iPad2,3"])
                NewDeviceType = @"iPad 2(CDMA)";
            else if ([DeviceType isEqualToString:@"iPad2,4"])
                NewDeviceType = @"iPad 2(WiFi + New Chip)";
            else if ([DeviceType isEqualToString:@"iPad2,5"])
                NewDeviceType = @"iPad mini(WiFi)";
            else if ([DeviceType isEqualToString:@"iPad2,6"])
                NewDeviceType = @"iPad mini(GSM)";
            else if ([DeviceType isEqualToString:@"iPad2,7"])
                NewDeviceType = @"iPad mini(GSM+CDMA)";
            else if ([DeviceType isEqualToString:@"iPad3,1"])
                NewDeviceType = @"iPad 3(WiFi)";
            else if ([DeviceType isEqualToString:@"iPad3,2"])
                NewDeviceType = @"iPad 3(GSM+CDMA)";
            else if ([DeviceType isEqualToString:@"iPad3,3"])
                NewDeviceType = @"iPad 3(GSM)";
            else if ([DeviceType isEqualToString:@"iPad3,4"])
                NewDeviceType = @"iPad 4(WiFi)";
            else if ([DeviceType isEqualToString:@"iPad3,5"])
                NewDeviceType = @"iPad 4(GSM)";
            else if ([DeviceType isEqualToString:@"iPad3,6"])
                NewDeviceType = @"iPad 4(GSM+CDMA)";
            else if ([DeviceType isEqualToString:@"iPad3,3"])
                NewDeviceType = @"New iPad";
            else if ([DeviceType isEqualToString:@"iPad4,1"])
                NewDeviceType = @"iPad Air(WiFi)";
            else if ([DeviceType isEqualToString:@"iPad4,2"])
                NewDeviceType = @"iPad Air(Cellular)";
            else if ([DeviceType isEqualToString:@"iPad4,4"])
                NewDeviceType = @"iPad mini 2(WiFi)";
            else if ([DeviceType isEqualToString:@"iPad4,5"])
                NewDeviceType = @"iPad mini 2(Cellular)";
            else if ([DeviceType isEqualToString:@"iPad4,6"])
                NewDeviceType = @"iPad mini 2(Rev)";
            else if ([DeviceType isEqualToString:@"iPad4,7"]||[DeviceType isEqualToString:@"iPad4,8"]||[DeviceType isEqualToString:@"iPad4,9"])
                NewDeviceType = @"iPad mini 3";
            else if ([DeviceType isEqualToString:@"iPad5,1"]||[DeviceType isEqualToString:@"iPad5,2"])
                NewDeviceType = @"iPad mini 4";
            else if ([DeviceType isEqualToString:@"iPad5,3"]||[DeviceType isEqualToString:@"iPad5,4"])
                NewDeviceType = @"iPad Air 2";
            else if ([DeviceType isEqualToString:@"iPad6,3"]||[DeviceType isEqualToString:@"iPad6,4"])
                NewDeviceType = @"iPad Pro(9.7 inch)";
            else if ([DeviceType isEqualToString:@"iPad6,7"]||[DeviceType isEqualToString:@"iPad6,8"])
                NewDeviceType = @"iPad Pro(12.9 inch)";
            else
                NewDeviceType=DeviceType;
            return NewDeviceType;
        }
        @catch (NSException *exception) {
            // Error
            return nil;
        }
    } else {
        // Unformatted
        @try {
            // Set up a struct
            struct utsname DT;
            // Get the system information
            uname(&DT);
            // Set the device type to the machine type
            DeviceType = [NSString stringWithFormat:@"%s", DT.machine];
            
            // Return the device type
            return DeviceType;
        }
        @catch (NSException *exception) {
            // Error
            return nil;
        }
    }
}

// Format the memory to a string in GB, MB, or Bytes
- (NSString *)formatMemory:(long long)Space {
    // Format the long long disk space
    @try {
        // Set up the string
        NSString *FormattedBytes = nil;
        
        // Get the bytes, megabytes, and gigabytes
        double NumberBytes = 1.0 * Space;
        double TotalGB = NumberBytes / GB;
        double TotalMB = NumberBytes / MB;
        
        // Display them appropriately
        if (TotalGB >= 1.0) {
            FormattedBytes = [NSString stringWithFormat:@"%.2f GB", TotalGB];
        } else if (TotalMB >= 1)
            FormattedBytes = [NSString stringWithFormat:@"%.2f MB", TotalMB];
        else {
            FormattedBytes = [self formattedMemory:Space];
            FormattedBytes = [FormattedBytes stringByAppendingString:@" bytes"];
        }
        
        // Check for errors
        if (FormattedBytes == nil || FormattedBytes.length <= 0) {
            // Error, invalid string
            return nil;
        }
        
        // Completed Successfully
        return FormattedBytes;
    }
    @catch (NSException *exception) {
        // Error
        return nil;
    }
}

// Format bytes to a string
- (NSString *)formattedMemory:(unsigned long long)Space {
    // Format for bytes
    @try {
        // Set up the string variable
        NSString *FormattedBytes = nil;
        
        // Set up the format variable
        NSNumberFormatter *Formatter = [[NSNumberFormatter alloc] init];
        
        // Format the bytes
        [Formatter setPositiveFormat:@"###,###,###,###"];
        
        // Get the bytes
        NSNumber * theNumber = [NSNumber numberWithLongLong:Space];
        
        // Format the bytes appropriately
        FormattedBytes = [Formatter stringFromNumber:theNumber];
        
        // Check for errors
        if (FormattedBytes == nil || FormattedBytes.length <= 0) {
            // Error, invalid value
            return nil;
        }
        
        // Completed Successfully
        return FormattedBytes;
    }
    @catch (NSException *exception) {
        // Error
        return nil;
    }
}

// Total Free Disk Space
- (NSString *)freeDiskSpace:(BOOL)inPercent {
    // Get the total free disk space
    @try {
        // Get the long size of free space
        long long Space = [self longFreeDiskSpace];
        
        // Check to make sure it's valid
        if (Space <= 0) {
            // Error, no disk space found
            return nil;
        }
        
        // Set up the string output variable
        NSString *DiskSpace;
        
        // If the user wants the output in percentage
        if (inPercent) {
            // Get the total amount of space
            long long TotalSpace = [self longDiskSpace];
            // Make a float to get the percent of those values
            float PercentDiskSpace = (Space * 100) / TotalSpace;
            // Check it to make sure it's okay
            if (PercentDiskSpace <= 0) {
                // Error, invalid percent
                return nil;
            }
            // Convert that float to a string
            DiskSpace = [NSString stringWithFormat:@"%.f%%", PercentDiskSpace];
        } else {
            // Turn that long long into a string
            DiskSpace = [self formatMemory:Space];
        }
        
        // Check to make sure it's valid
        if (DiskSpace == nil || DiskSpace.length <= 0) {
            // Error, diskspace not given
            return nil;
        }
        
        // Return successful
        return DiskSpace;
    }
    @catch (NSException * ex) {
        // Error
        return nil;
    }
}

// Total Used Disk Space
- (NSString *)usedDiskSpace:(BOOL)inPercent {
    // Get the total used disk space
    @try {
        // Make a variable to hold the Used Disk Space
        long long UDS;
        // Get the long total disk space
        long long TDS = [self longDiskSpace];
        // Get the long free disk space
        long long FDS = [self longFreeDiskSpace];
        
        // Make sure they're valid
        if (TDS <= 0 || FDS <= 0) {
            // Error, invalid values
            return nil;
        }
        
        // Now subtract the free space from the total space
        UDS = TDS - FDS;
        
        // Make sure it's valid
        if (UDS <= 0) {
            // Error, invalid value
            return nil;
        }
        
        // Set up the string output variable
        NSString *UsedDiskSpace;
        
        // If the user wants the output in percentage
        if (inPercent) {
            // Make a float to get the percent of those values
            float PercentUsedDiskSpace = (UDS * 100) / TDS;
            // Check it to make sure it's okay
            if (PercentUsedDiskSpace <= 0) {
                // Error, invalid percent
                return nil;
            }
            // Convert that float to a string
            UsedDiskSpace = [NSString stringWithFormat:@"%.f%%", PercentUsedDiskSpace];
        } else {
            // Turn that long long into a string
            UsedDiskSpace = [self formatMemory:UDS];
        }
        
        // Check to make sure it's valid
        if (UsedDiskSpace == nil || UsedDiskSpace.length <= 0) {
            // Error, diskspace not given
            return nil;
        }
        
        // Return successful
        return UsedDiskSpace;
        
        // Now convert that to a string
    }
    @catch (NSException *exception) {
        // Error
        return nil;
    }
}


@end

