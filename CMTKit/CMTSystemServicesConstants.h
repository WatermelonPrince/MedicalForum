//
//  CMTSystemServicesConstants.h
//  MedicalForum
//
//  Created by fenglei on 14/12/2.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

// System Frameworks
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

// Headers
#import <arpa/inet.h>
#include <errno.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#import <sys/sysctl.h>
#import <sys/utsname.h>
#import <sys/times.h>
#import <sys/stat.h>
#import <sys/_structs.h>
#import <asl.h>
#import <ifaddrs.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#include <stdio.h>
#import <TargetConditionals.h>

// Defines
#define MB (1024*1024)
#define GB (MB*1024)