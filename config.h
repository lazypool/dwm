#ifndef CONFIG_H
#define CONFIG_H
// clang-format off

#include "dwm.h"

/* appearance */
const unsigned int borderpx = 3;  /* border pixel of windows */
const unsigned int snap     = 32; /* snap pixel */
const int showbar           = 1;  /* 0 means no bar */
const int topbar            = 1;  /* 0 means bottom bar */
const int sidepad           = 6;  /* side padding size */
const int iconsize          = 24; /* icon size */
const int iconspacing       = 8;  /* space between icon and title */
const int ulpad             = 5;  /* horizontal padding between underline and tag */
const int ulstroke          = 3;  /* thickness of the underline */
const char *fonts[]         = {"Iosevka:style:medium:size=12" ,"JetBrainsMono Nerd Font Mono:style:medium:size=19" };
const char dmenufont[]      = "JetBrainsMono Nerd Font Mono:size=12";
const char col_gray1[]      = "#222222";
const char col_gray2[]      = "#444444";
const char col_gray3[]      = "#bbbbbb";
const char col_gray4[]      = "#eeeeee";
const char col_cyan[]       = "#005577";
const char *colors[][3]     = {
	/*               fg         bg         border   */
	[SchemeNorm] = {col_gray3, col_gray1, col_gray2},
	[SchemeSel]  = {col_gray4, col_cyan,  col_cyan },
};

/* self-defined scripts */
const char *autostartscript = "$DWM/autostart.sh";
const char *statusbarscript = "$DWM/statusbar.sh";

/* tags */
const char *tags[MAXTAGS] = {"", "", "", "", "", "", "", ""};

/* rule */
const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class    instance  title              tagmask  isfloating  isglobal  monitor  unmanaged*/
	{"Gimp",    NULL,     NULL,              0,       1,          0,        -1,      0},
	{"Firefox", NULL,     NULL,              1 << 8,  0,          0,        -1,      0},
	{NULL,      NULL,     "Feishu Meetings", 0,       0,          0,        -1,      1},
	{NULL,      NULL,     "broken",          0,       0,          0,        -1,      1},
};

/* layout(s) */
const float mfact        = 0.55; /* factor of master area size [0.05..0.95] */
const int nmaster        = 1;    /* number of clients in master area */
const int resizehints    = 0;    /* 1 means respect size hints in tiled resizals */
const int lockfullscreen = 1;    /* 1 will force focus on the fullscreen window */
const char *monsyms[]    = {"󰎡", "󰎤", "󰎧", "󰎪", "󰎭", "󰎱", "󰎳", "󰎶", "󰎹", "󰎼", "󰎿"};

const Layout layouts[] = {
	/* symbol  function */
	{"󰙀",    tile   }, /* first entry is default */
	{"󰗣",    NULL   }, /* no layout function means floating behavior */
	{"󰎡",    monocle},
};

/* commands */
char dmenumon[2]       = "0"; /* component of dmenucmd, manipulated in spawn() */
const char *dmenucmd[] = {"dmenu_run", "-m", dmenumon, "-fn", dmenufont, "-nb", col_gray1, "-nf", col_gray3, "-sb", col_cyan, "-sf", col_gray4, NULL};
const char *termcmd[]  = {"st", NULL};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY, MSK)                               \
	{MODKEY, KEY, view, {.ui = MSK}},                     \
	{MODKEY | ControlMask, KEY, toggleview, {.ui = MSK}}, \
	{MODKEY | ShiftMask, KEY, viewontag, {.ui = MSK}},    \
	{MODKEY | ControlMask | ShiftMask, KEY, tag, {.ui = MSK}},

const Key keys[] = {
	/* modifier          key        function        argument */
	{MODKEY,             XK_p,      spawn,          {.v = dmenucmd}   },
	{MODKEY | ShiftMask, XK_Return, spawn,          {.v = termcmd}    },
	{MODKEY,             XK_b,      togglebar,      {0}               },
	{MODKEY,             XK_e,      focusstack,     {.i = +1}         },
	{MODKEY,             XK_u,      focusstack,     {.i = -1}         },
	{MODKEY,             XK_h,      setmfact,       {.f = -0.05}      },
	{MODKEY,             XK_l,      setmfact,       {.f = +0.05}      },
	{MODKEY,             XK_o,      transfer,       {0}               },
	{MODKEY,             XK_Return, zoom,           {0}               },
	{MODKEY,             XK_Tab,    view,           {0}               },
	{MODKEY | ShiftMask, XK_c,      killclient,     {0}               },
	{MODKEY,             XK_t,      setlayout,      {.v = &layouts[0]}},
	{MODKEY,             XK_f,      setlayout,      {.v = &layouts[1]}},
	{MODKEY,             XK_m,      setlayout,      {.v = &layouts[2]}},
	{MODKEY,             XK_space,  setlayout,      {0}               },
	{MODKEY | ShiftMask, XK_space,  togglefloating, {0}               },
	{MODKEY,             XK_g,      toggleglobal,   {0}               },
	{MODKEY,             XK_0,      view,           {.ui = ~0}        },
	{MODKEY,             XK_comma,  focusmon,       {.i = -1}         },
	{MODKEY,             XK_period, focusmon,       {.i = +1}         },
	{MODKEY | ShiftMask, XK_comma,  tagmon,         {.i = -1}         },
	{MODKEY | ShiftMask, XK_period, tagmon,         {.i = +1}         },
	{MODKEY | ShiftMask, XK_q,      quit,           {0}               },
	TAGKEYS(XK_1, TAG(0)) TAGKEYS(XK_2, TAG(1)) TAGKEYS(XK_3, TAG(2))
	TAGKEYS(XK_4, TAG(3)) TAGKEYS(XK_5, TAG(4)) TAGKEYS(XK_6, TAG(5))
	TAGKEYS(XK_7, TAG(6)) TAGKEYS(XK_8, TAG(7)) TAGKEYS(XK_9, TAGHIDE)
};

/* button definitions */
const Button buttons[] = {
	/* click        mod     button    function       argument */
	{ClkLtSymbol,   0,      Button1, setlayout,      {0}               },
	{ClkLtSymbol,   0,      Button3, setlayout,      {.v = &layouts[2]}},
	{ClkWinTitle,   0,      Button2, zoom,           {0}               },
	{ClkStatusText, 0,      Button1, clkstatusbar,   {0}               },
	{ClkStatusText, 0,      Button2, clkstatusbar,   {0}               },
	{ClkStatusText, 0,      Button3, clkstatusbar,   {0}               },
	{ClkStatusText, 0,      Button4, clkstatusbar,   {0}               },
	{ClkStatusText, 0,      Button5, clkstatusbar,   {0}               },
	{ClkClientWin,  MODKEY, Button1, movemouse,      {0}               },
	{ClkClientWin,  MODKEY, Button2, togglefloating, {0}               },
	{ClkClientWin,  MODKEY, Button3, resizemouse,    {0}               },
	{ClkTagBar,     0,      Button1, view,           {0}               },
	{ClkTagBar,     0,      Button3, toggleview,     {0}               },
	{ClkTagBar,     MODKEY, Button1, viewontag,      {0}               },
	{ClkTagBar,     MODKEY, Button3, tag,            {0}               },
};

// clang-format on
#endif  // !CONFIG_H
