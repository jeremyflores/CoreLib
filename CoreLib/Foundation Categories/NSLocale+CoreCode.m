//
//  NSLocale+CoreCode.m
//  MacUpdater
//
//  Created by Carterhaugh LLC on 8/16/23.
//  Copyright © 2023 CoreCode Limited. All rights reserved.
//

#import "NSLocale+CoreCode.h"

#import "CLDispatch.h"
#import "CLMakers.h"
#import "CLLogic.h"

@implementation NSLocale (CoreCode)

+ (NSArray *)preferredLanguages2Letter
{
    static NSMutableArray *languageCodes;
    
    ONCE_PER_FUNCTION(^
    {
        languageCodes = makeMutableArray();
    
        for (NSString *l in NSLocale.preferredLanguages)
        {
            NSDictionary *d = [NSLocale componentsFromLocaleIdentifier:l];
            NSString *twoLetterCode = d[NSLocaleLanguageCode];
            [languageCodes addObject:twoLetterCode];
        }
    })
    
    return languageCodes;
}
+ (NSArray *)preferredLanguages3Letter
{
    NSDictionary *iso2LetterTo3Letter = @{@"aa" : @"aar", @"ab" : @"abk", @"ae" : @"ave", @"af" : @"afr", @"ak" : @"aka", @"am" : @"amh", @"an" : @"arg", @"ar" : @"ara", @"as" : @"asm", @"av" : @"ava", @"ay" : @"aym", @"az" : @"aze", @"ba" : @"bak", @"be" : @"bel", @"bg" : @"bul", @"bh" : @"bih", @"bi" : @"bis", @"bm" : @"bam", @"bn" : @"ben", @"bo" : @"tib", @"br" : @"bre", @"bs" : @"bos", @"ca" : @"cat", @"ce" : @"che", @"ch" : @"cha", @"co" : @"cos", @"cr" : @"cre", @"cs" : @"cze", @"cu" : @"chu", @"cv" : @"chv", @"cy" : @"wel", @"da" : @"dan", @"de" : @"ger", @"dv" : @"div", @"dz" : @"dzo", @"ee" : @"ewe", @"el" : @"gre", @"en" : @"eng", @"eo" : @"epo", @"es" : @"spa", @"et" : @"est", @"eu" : @"baq", @"fa" : @"per", @"ff" : @"ful", @"fi" : @"fin", @"fj" : @"fij", @"fo" : @"fao", @"fr" : @"fre", @"fy" : @"fry", @"ga" : @"gle", @"gd" : @"gla", @"gl" : @"glg", @"gn" : @"grn", @"gu" : @"guj", @"gv" : @"glv", @"ha" : @"hau", @"he" : @"heb", @"hi" : @"hin", @"ho" : @"hmo", @"hr" : @"hrv", @"ht" : @"hat", @"hu" : @"hun", @"hy" : @"arm", @"hz" : @"her", @"ia" : @"ina", @"id" : @"ind", @"ie" : @"ile", @"ig" : @"ibo", @"ii" : @"iii", @"ik" : @"ipk", @"io" : @"ido", @"is" : @"ice", @"it" : @"ita", @"iu" : @"iku", @"ja" : @"jpn", @"jv" : @"jav", @"ka" : @"geo", @"kg" : @"kon", @"ki" : @"kik", @"kj" : @"kua", @"kk" : @"kaz", @"kl" : @"kal", @"km" : @"khm", @"kn" : @"kan", @"ko" : @"kor", @"kr" : @"kau", @"ks" : @"kas", @"ku" : @"kur", @"kv" : @"kom", @"kw" : @"cor", @"ky" : @"kir", @"la" : @"lat", @"lb" : @"ltz", @"lg" : @"lug", @"li" : @"lim", @"ln" : @"lin", @"lo" : @"lao", @"lt" : @"lit", @"lu" : @"lub", @"lv" : @"lav", @"mg" : @"mlg", @"mh" : @"mah", @"mi" : @"mao", @"mk" : @"mac", @"ml" : @"mal", @"mn" : @"mon", @"mr" : @"mar", @"ms" : @"may", @"mt" : @"mlt", @"my" : @"bur", @"na" : @"nau", @"nb" : @"nob", @"nd" : @"nde", @"ne" : @"nep", @"ng" : @"ndo", @"nl" : @"dut", @"nn" : @"nno", @"no" : @"nor", @"nr" : @"nbl", @"nv" : @"nav", @"ny" : @"nya", @"oc" : @"oci", @"oj" : @"oji", @"om" : @"orm", @"or" : @"ori", @"os" : @"oss", @"pa" : @"pan", @"pi" : @"pli", @"pl" : @"pol", @"ps" : @"pus", @"pt" : @"por", @"qu" : @"que", @"rm" : @"roh", @"rn" : @"run", @"ro" : @"rum", @"ru" : @"rus", @"rw" : @"kin", @"sa" : @"san", @"sc" : @"srd", @"sd" : @"snd", @"se" : @"sme", @"sg" : @"sag", @"si" : @"sin", @"sk" : @"slo", @"sl" : @"slv", @"sm" : @"smo", @"sn" : @"sna", @"so" : @"som", @"sq" : @"alb", @"sr" : @"srp", @"ss" : @"ssw", @"st" : @"sot", @"su" : @"sun", @"sv" : @"swe", @"sw" : @"swa", @"ta" : @"tam", @"te" : @"tel", @"tg" : @"tgk", @"th" : @"tha", @"ti" : @"tir", @"tk" : @"tuk", @"tl" : @"tgl", @"tn" : @"tsn", @"to" : @"ton", @"tr" : @"tur", @"ts" : @"tso", @"tt" : @"tat", @"tw" : @"twi", @"ty" : @"tah", @"ug" : @"uig", @"uk" : @"ukr", @"ur" : @"urd", @"uz" : @"uzb", @"ve" : @"ven", @"vi" : @"vie", @"vo" : @"vol", @"wa" : @"wln", @"wo" : @"wol", @"xh" : @"xho", @"yi" : @"yid", @"yo" : @"yor", @"za" : @"zha", @"zh" : @"chi", @"zu" : @"zul"};

    NSMutableArray *tmp = [NSMutableArray new];
    
    for (NSString *twoLetterCode in [NSLocale preferredLanguages])
    {
        NSString *threeLetterCode = iso2LetterTo3Letter[twoLetterCode];
        
        if (threeLetterCode)
            [tmp addObject:threeLetterCode];
        else
        {
            NSDictionary *d = [NSLocale componentsFromLocaleIdentifier:twoLetterCode];
            NSString *backupTwoLetterCode = d[NSLocaleLanguageCode];
            NSString *backupThreeLetterCode = iso2LetterTo3Letter[backupTwoLetterCode];

            [tmp addObject:(OBJECT_OR(backupThreeLetterCode, twoLetterCode))];
        }
    }

    return [NSArray arrayWithArray:tmp];
}


@end
