/******************************************************************************
 *                                                                            *
 * Copyright (C) 2010 by Ben Cressey                                          *
 *                                                                            *
 * This file is part of Gargoyle.                                             *
 *                                                                            *
 * Gargoyle is free software; you can redistribute it and/or modify           *
 * it under the terms of the GNU General Public License as published by       *
 * the Free Software Foundation; either version 2 of the License, or          *
 * (at your option) any later version.                                        *
 *                                                                            *
 * Gargoyle is distributed in the hope that it will be useful,                *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of             *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              *
 * GNU General Public License for more details.                               *
 *                                                                            *
 * You should have received a copy of the GNU General Public License          *
 * along with Gargoyle; if not, write to the Free Software                    *
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA *
 *                                                                            *
 *****************************************************************************/

#import "Cocoa/Cocoa.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "glk.h"
#include "garglk.h"

static int gli_sys_monor = FALSE;
static int gli_sys_monob = FALSE;
static int gli_sys_monoi = FALSE;
static int gli_sys_monoz = FALSE;

void monofont(char *file, int style)
{
    switch (style)
    {
        case FONTR:
        {
            if (!gli_sys_monor)
            {
                gli_conf_monor = file;

                if (!gli_sys_monob)
                    gli_conf_monob = file;

                if (!gli_sys_monoi)
                    gli_conf_monoi = file;

                if (!gli_sys_monoz && !gli_sys_monoi && !gli_sys_monob)
                    gli_conf_monoz = file;

                gli_sys_monor = TRUE;
            }
            return;
        }

        case FONTB:
        {
            if (!gli_sys_monob)
            {
                gli_conf_monob = file;

                if (!gli_sys_monoz && !gli_sys_monoi)
                    gli_conf_monoz = file;

                gli_sys_monob = TRUE;
            }
            return;
        }

        case FONTI:
        {
            if (!gli_sys_monoi)
            {
                gli_conf_monoi = file;

                if (!gli_sys_monoz)
                    gli_conf_monoz = file;

                gli_sys_monoi = TRUE;
            }
            return;
        }

        case FONTZ:
        {
            if (!gli_sys_monoz)
            {
                gli_conf_monoz = file;
                gli_sys_monoz = TRUE;
            }
            return;
        }
    }
}

static int gli_sys_propr = FALSE;
static int gli_sys_propb = FALSE;
static int gli_sys_propi = FALSE;
static int gli_sys_propz = FALSE;

void propfont(char *file, int style)
{
    switch (style)
    {
        case FONTR:
        {
            if (!gli_sys_propr)
            {
                gli_conf_propr = file;

                if (!gli_sys_propb)
                    gli_conf_propb = file;

                if (!gli_sys_propi)
                    gli_conf_propi = file;

                if (!gli_sys_propz && !gli_sys_propi && !gli_sys_propb)
                    gli_conf_propz = file;

                gli_sys_propr = TRUE;
            }
            return;
        }

        case FONTB:
        {
            if (!gli_sys_propb)
            {
                gli_conf_propb = file;

                if (!gli_sys_propz && !gli_sys_propi)
                    gli_conf_propz = file;

                gli_sys_propb = TRUE;
            }
            return;
        }

        case FONTI:
        {
            if (!gli_sys_propi)
            {
                gli_conf_propi = file;

                if (!gli_sys_propz)
                    gli_conf_propz = file;

                gli_sys_propi = TRUE;
            }
            return;
        }

        case FONTZ:
        {
            if (!gli_sys_propz)
            {
                gli_conf_propz = file;
                gli_sys_propz = TRUE;
            }
            return;
        }
    }
}

void winfont(char *font, int type)
{
    if (!strlen(font))
        return;

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    NSEnumerator * sysfonts = [[[[NSFontDescriptor fontDescriptorWithFontAttributes:nil] 
                                 fontDescriptorWithFamily: [NSString stringWithCString: font 
                                                                              encoding: NSASCIIStringEncoding]]
                                matchingFontDescriptorsWithMandatoryKeys: nil]
                               objectEnumerator];
    id sysfont;
    FSRef fileref;
    ATSFontRef fontref;
    int style;

    while (sysfont = [sysfonts nextObject])
    {
        /* find style for font */
        style = FONTR;

        if (([sysfont symbolicTraits] & NSFontBoldTrait) && ([sysfont symbolicTraits] & NSFontItalicTrait))
            style = FONTZ;

        else if ([sysfont symbolicTraits] & NSFontBoldTrait)
            style = FONTB;

        else if ([sysfont symbolicTraits] & NSFontItalicTrait)
            style = FONTI;

        /* find path for font */
        fontref = ATSFontFindFromPostScriptName((CFStringRef) [sysfont objectForKey: NSFontNameAttribute], kATSOptionFlagsDefault);
        ATSFontGetFileReference(fontref, &fileref);

        unsigned char * filebuf = malloc(4 * PATH_MAX);
        filebuf[0] = '\0';

        FSRefMakePath(&fileref, filebuf, 4 * PATH_MAX - 1);

        if (strlen(filebuf))
        {
            switch (type)
            {
                case MONOF:
                    monofont(filebuf, style);
                    break;

                case PROPF:
                    propfont(filebuf, style);
                    break;
            }
        }
    }

    [pool drain];
}