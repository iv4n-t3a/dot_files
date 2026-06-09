/* See LICENSE file for copyright and license details. */

#include <X11/XF86keysym.h>

/* appearance */
static const unsigned int borderpx  = 2;        /* border pixel of windows */
static const unsigned int default_border = 1;   /* to switch back to default border after dynamic border resizing via keybinds */
static const unsigned int snap      = 32;       /* snap pixel */
static const unsigned int gappih    = 10;       /* horiz inner gap between windows */
static const unsigned int gappiv    = 10;       /* vert inner gap between windows */
static const unsigned int gappoh    = 10;       /* horiz outer gap between windows and screen edge */
static const unsigned int gappov    = 10;       /* vert outer gap between windows and screen edge */
static const int smartgaps          = 0;        /* 1 means no outer gap when there is only one window */
static const unsigned int systraypinning = 0;   /* 0: sloppy systray follows selected monitor, >0: pin systray to monitor X */
static const unsigned int systrayspacing = 2;   /* systray spacing */
static const int systraypinningfailfirst = 1;   /* 1: if pinning fails,display systray on the 1st monitor,False: display systray on last monitor*/
static const int showsystray        = 0;        /* 0 means no systray */
static const int showbar            = 1;        /* 0 means no bar */
static const int showtab            = showtab_auto;
static const int toptab             = 1;        /* 0 means bottom tab */
static const int floatbar           = 1;/* 1 means the bar will float(don't have padding),0 means the bar have padding */
static const int topbar             = 1;        /* 0 means bottom bar */
static const int horizpadbar        = 5;
static const int vertpadbar         = 11;
static const int vertpadtab         = 35;
static const int horizpadtabi       = 15;
static const int horizpadtabo       = 15;
static const int scalepreview       = 4;
static const int tag_preview        = 1;        /* 1 means enable, 0 is off */
static const int colorfultag        = 1;        /* 0 means use SchemeSel for selected non vacant tag */
static const char *upvol[]   = { "/usr/bin/pactl", "set-sink-volume", "0", "+5%",     NULL };
static const char *downvol[] = { "/usr/bin/pactl", "set-sink-volume", "0", "-5%",     NULL };
static const char *mutevol[] = { "/usr/bin/pactl", "set-sink-mute",   "0", "toggle",  NULL };
static const char *light_up[] = {"/usr/bin/light", "-A", "5", NULL};
static const char *light_down[] = {"/usr/bin/light", "-U", "5", NULL};
static const int new_window_attach_on_end = 0; /*  1 means the new window will attach on the end; 0 means the new window will attach on the front,default is front */
#define ICONSIZE 19   /* icon size */
#define ICONSPACING 8 /* space between icon and title */

static const char *fonts[]          = {"Iosevka:style:medium:size=12" ,"JetBrainsMono Nerd Font Mono:style:medium:size=19" };

// theme
#include "themes/onedark.h"

static const char *colors[][3]      = {
    /*                     fg       bg      border */
    [SchemeNorm]       = { gray3,   black,  gray2 },
    [SchemeSel]        = { gray4,   blue,   blue  },
    [SchemeTitle]      = { white,   black,  black }, // active window title
    [TabSel]           = { blue,    gray2,  black },
    [TabNorm]          = { gray3,   black,  black },
    [SchemeTag]        = { gray3,   black,  black },
    [SchemeTag1]       = { blue,    black,  black },
    [SchemeTag2]       = { red,     black,  black },
    [SchemeTag3]       = { orange,  black,  black },
    [SchemeTag4]       = { green,   black,  black },
    [SchemeTag5]       = { pink,    black,  black },
    [SchemeLayout]     = { green,   black,  black },
    [SchemeBtnPrev]    = { green,   black,  black },
    [SchemeBtnNext]    = { yellow,  black,  black },
    [SchemeBtnClose]   = { red,     black,  black },
};

/* tagging */
/* static char *tags[] = {"", "", "", "", ""}; */
static char *tags[] = {"1", "2", "3", "4", "5", "", "󰖟"};

static const char* eww[] = { "eww", "open" , "eww", NULL };

static const Launcher launchers[] = {
    /* command     name to display */
    { eww,         "" },
};

static const int tagschemes[] = {
    SchemeTag1, SchemeTag2, SchemeTag3, SchemeTag4, SchemeTag5, SchemeTag1, SchemeTag2
};

static const unsigned int ulinepad      = 5; /* horizontal padding between the underline and tag */
static const unsigned int ulinestroke   = 2; /* thickness / height of the underline */
static const unsigned int ulinevoffset  = 0; /* how far above the bottom of the bar the line should appear */
static const int ulineall               = 0; /* 1 to show underline on all tags, 0 for just the active ones */

static const Rule rules[] = {
    /* xprop(1):
     *	WM_CLASS(STRING) = instance, class
     *	WM_NAME(STRING) = title
     */
    /* class                  instance    title       tags mask     iscentered   isfloating   monitor */
    { "Gimp",                 NULL,       NULL,       0,             0,           0,           -1 },
    { "Firefox",              NULL,       NULL,       1 << 6,        0,           0,           -1 },
    { "qutebrowser",          NULL,       NULL,       1 << 6,        0,           0,           -1 },
	  { "TelegramDesktop",      NULL,       NULL,       1 << 5,        0,           0,           -1 },
    { "eww",                  NULL,       NULL,       0,             0,           1,           -1 },
    { "zenity",               NULL,       NULL,       0,             1,           1,           -1 },
};

/* layout(s) */
static const float mfact     = 0.50; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 0;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */

#define FORCE_VSPLIT 1  /* nrowgrid layout: force two clients to always split vertically */
#include "functions.h"


static const Layout layouts[] = {
    /* symbol     arrange function */
    { "[]=",      tile },    /* first entry is default */
    { "[M]",      monocle },
    { "[@]",      spiral },
    { "[\\]",     dwindle },
    { "H[]",      deck },
    { "TTT",      bstack },
    { "===",      bstackhoriz },
    { "HHH",      grid },
    { "###",      nrowgrid },
    { "---",      horizgrid },
    { ":::",      gaplessgrid },
    { "|M|",      centeredmaster },
    { ">M>",      centeredfloatingmaster },
    { "><>",      NULL },    /* no layout function means floating behavior */
    { NULL,       NULL },
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
    { MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
    { MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
    { MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
    { MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/bash", "-c", cmd, NULL } }
#define EXECCMD(cmd...) { .v = (const char*[]){ cmd, NULL } }
#define TERMRUN(cmd...) { .v = (const char*[]){ "alacritty", "-e", cmd, NULL } }
#define STRUN(cmd...) { .v = (const char*[]){ "st", "-f", "monospace:size=12","-e", cmd, NULL } }
#define PYTHON(cmd) { .v = (const char*[]){ "python3", cmd, NULL } }

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *termcmd[] = {"alacritty", NULL};
static const char *dmenucmd[] = {"rofi", "drun", "-show", "drun", "-mathcing", "fuzzy", NULL};

#define HOME "/home/ivan/"

/* commands */

static const Key keys[] = {
    /* modifier                         key         function        argument */
    { MODKEY,                           XK_p,       spawn,           {.v = dmenucmd} },
    { MODKEY|ShiftMask,                 XK_Return,  spawn,           {.v = termcmd} },

    // toggle stuff
    { MODKEY,                           XK_b,       togglebar,      {0} },
    { MODKEY|ShiftMask,                 XK_space,   togglefloating, {0} },
    { MODKEY,                           XK_f,       togglefullscr,  {0} },

    { MODKEY|ControlMask,               XK_w,       tabmode,        { -1 } },
    { MODKEY,                           XK_j,       focusstack,     {.i = +1 } },
    { MODKEY,                           XK_k,       focusstack,     {.i = -1 } },
    { MODKEY,                           XK_i,       incnmaster,     {.i = +1 } },
    { MODKEY,                           XK_d,       incnmaster,     {.i = -1 } },

    // change m,cfact sizes
    { MODKEY,                           XK_h,       setmfact,       {.f = -0.05} },
    { MODKEY,                           XK_l,       setmfact,       {.f = +0.05} },
    { MODKEY|ShiftMask,                 XK_h,       setcfact,       {.f = +0.25} },
    { MODKEY|ShiftMask,                 XK_l,       setcfact,       {.f = -0.25} },
    { MODKEY|ShiftMask,                 XK_o,       setcfact,       {.f =  0.00} },


    { MODKEY|ShiftMask,                 XK_j,       movestack,      {.i = +1 } },
    { MODKEY|ShiftMask,                 XK_k,       movestack,      {.i = -1 } },
    { MODKEY,                           XK_Tab,     view,           {0} },

    // overall gaps
    { MODKEY|ControlMask,               XK_i,       incrgaps,       {.i = +1 } },
    { MODKEY|ControlMask,               XK_d,       incrgaps,       {.i = -1 } },

    // inner gaps
    { MODKEY|ShiftMask,                 XK_i,       incrigaps,      {.i = +1 } },
    { MODKEY|ControlMask|ShiftMask,     XK_i,       incrigaps,      {.i = -1 } },

    // outer gaps
    { MODKEY|ControlMask,               XK_o,       incrogaps,      {.i = +1 } },
    { MODKEY|ControlMask|ShiftMask,     XK_o,       incrogaps,      {.i = -1 } },

    // inner+outer hori, vert gaps
    { MODKEY|ControlMask,               XK_6,       incrihgaps,     {.i = +1 } },
    { MODKEY|ControlMask|ShiftMask,     XK_6,       incrihgaps,     {.i = -1 } },
    { MODKEY|ControlMask,               XK_7,       incrivgaps,     {.i = +1 } },
    { MODKEY|ControlMask|ShiftMask,     XK_7,       incrivgaps,     {.i = -1 } },
    { MODKEY|ControlMask,               XK_8,       incrohgaps,     {.i = +1 } },
    { MODKEY|ControlMask|ShiftMask,     XK_8,       incrohgaps,     {.i = -1 } },
    { MODKEY|ControlMask,               XK_9,       incrovgaps,     {.i = +1 } },
    { MODKEY|ControlMask|ShiftMask,     XK_9,       incrovgaps,     {.i = -1 } },

    { MODKEY|ControlMask|ShiftMask,     XK_d,       defaultgaps,    {0} },

    // layout
    { MODKEY,                           XK_t,       setlayout,      {.v = &layouts[0]} },
    { MODKEY,                           XK_m,       setlayout,      {.v = &layouts[1]} },
    { MODKEY,                           XK_g,       setlayout,      {.v = &layouts[10]} },
    { MODKEY|ControlMask,               XK_f,       setlayout,      {.v = &layouts[13]} },
    /* { MODKEY|ControlMask|ShiftMask,     XK_t,       setlayout,      {.v = &layouts[13]} }, */

    { MODKEY,                           XK_space,   setlayout,      {0} },
    { MODKEY|ControlMask,               XK_comma,   cyclelayout,    {.i = -1 } },
    { MODKEY|ControlMask,               XK_period,  cyclelayout,    {.i = +1 } },
    { MODKEY,                           XK_0,       view,           {.ui = ~0 } },
    { MODKEY|ShiftMask,                 XK_0,       tag,            {.ui = ~0 } },
    { MODKEY,                           XK_comma,   focusmon,       {.i = -1 } },
    { MODKEY,                           XK_period,  focusmon,       {.i = +1 } },
    { MODKEY|ShiftMask,                 XK_comma,   tagmon,         {.i = -1 } },
    { MODKEY|ShiftMask,                 XK_period,  tagmon,         {.i = +1 } },
  	{ MODKEY,                           XK_Return,  zoom,           {0} },


    // change border size
    /* { MODKEY|ShiftMask,                 XK_minus,   setborderpx,    {.i = -1 } }, */
    /* { MODKEY|ShiftMask,                 XK_p,       setborderpx,    {.i = +1 } }, */
    /* { MODKEY|ShiftMask,                 XK_w,       setborderpx,    {.i = default_border } }, */

    { MODKEY|ShiftMask,                 XK_c,       killclient,     {0} },
    /* { MODKEY|ShiftMask,                 XK_q,       restart,        {0} }, */

    { MODKEY,                           XK_e,       hidewin,        {0} },
    { MODKEY|ShiftMask,                 XK_e,       restorewin,     {0} },

    TAGKEYS(                            XK_1,                       0)
    TAGKEYS(                            XK_2,                       1)
    TAGKEYS(                            XK_3,                       2)
    TAGKEYS(                            XK_4,                       3)
    TAGKEYS(                            XK_5,                       4)
    TAGKEYS(                            XK_7,                       4)
    TAGKEYS(                            XK_8,                       5)
    TAGKEYS(                            XK_9,                       6)

    { MODKEY,                           XK_q,       spawn,          EXECCMD("dm-tool", "lock") },
  	{ MODKEY,                           XK_s,       spawn,          SHCMD("pass show --clip $(zenity --entry --text passname --title passname)") },
  	/* { MODKEY,                           XK_s,       spawn,          SHCMD("pass show --clip ${$(ls .password-store | rofi -dmenu)%.*}") }, */
  	{ MODKEY,                           XK_n,       spawn,          SHCMD("pass generate --no-symbols --clip $(zenity --entry --text passname --title passname)") },
  	/* { MODKEY,                           XK_i,       spawn,          SHCMD("notify-send $(curl ifconfig.me)") }, */
  	{ 0,                                XK_Print,   spawn,          EXECCMD("sh", HOME"Scripts/scrsh.sh") },
  	{ MODKEY,                           XK_r,       spawn,          SHCMD("feh --bg-fill --randomize ~/Wallpapers/*") },
    { MODKEY,                           XK_w,       spawn,          SHCMD("cd ~/Wallpapers && feh --bg-fill \"$(ls | rofi -dmenu)\"") },
  	{ MODKEY|ShiftMask,                 XK_b,       spawn,          EXECCMD("firefox") },
  	{ MODKEY|ShiftMask,                 XK_p,       spawn,          TERMRUN("python3") },
  	{ MODKEY|ShiftMask,                 XK_s,       spawn,          EXECCMD("flameshot", "gui") },
  	{ MODKEY|ShiftMask,                 XK_h,       spawn,          TERMRUN("htop") },
  	{ MODKEY|ShiftMask,                 XK_n,       spawn,          TERMRUN("newsboat") },
  	{ MODKEY|ShiftMask,                 XK_r,       spawn,          TERMRUN("pyradio") },
  	{ MODKEY|ShiftMask,                 XK_f,       spawn,          TERMRUN("vifm") },
  	{ MODKEY|ShiftMask,                 XK_t,       spawn,          EXECCMD("telegram-desktop") },
  	{ MODKEY|ShiftMask,                 XK_g,       spawn,          TERMRUN("gtypist") },
  	{ MODKEY|ShiftMask,                 XK_i,       spawn,          TERMRUN("iwctl") },
  	{ MODKEY|ShiftMask,                 XK_z,       spawn,          TERMRUN("bluetoothctl") },
  	{ MODKEY|ShiftMask,                 XK_m,       spawn,          TERMRUN("mocp", "-C", HOME".moc/config.in") },
  	{ MODKEY|ShiftMask,                 XK_a,       spawn,          TERMRUN("alsamixer") },
    /* { MODKEY,                          XK_F10,    spawn,          EXECCMD("amixer", "set", "Master", "toggle") }, */
    /* { MODKEY,                          XK_F11,    spawn,          EXECCMD("amixer", "-q", "set", "Master", "5%-", "unmute") }, */
    /* { MODKEY,                          XK_F12,    spawn,          EXECCMD("amixer", "-q", "set", "Master", "5%+", "unmute") }, */
    /* { MODKEY,                          XK_F5,     spawn,          EXECCMD("light", "-U", "2") }, */
    /* { MODKEY,                          XK_F6,     spawn,          EXECCMD("light", "-A", "2") }, */
    { MODKEY,                           XK_Down,    spawn,          EXECCMD("mocp", "-G") },
    { MODKEY,                           XK_Up,      spawn,          SHCMD("cd ~/Music && mocp -l \"$(ls | rofi -dmenu)\"") },
    { MODKEY,                           XK_Left,    spawn,          EXECCMD("mocp", "-r") },
    { MODKEY,                           XK_Right,   spawn,          EXECCMD("mocp", "-f") },
    { MODKEY|ShiftMask,                 XK_Up,      spawn,          EXECCMD("mocp", "-p") },
  	{ ControlMask,                      XK_space,   spawn,          EXECCMD("dunstctl", "close-all") },
    { MODKEY|ControlMask,               XK_Return,  spawn,          EXECCMD("autorandr", "--load", "horizontal") }
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
    /* click                event mask      button          function        argument */
    { ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
    { ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
    { ClkWinTitle,          0,              Button2,        zoom,           {0} },
    { ClkStatusText,        0,              Button2,        spawn,          SHCMD("st") },

    /* Keep movemouse? */
    /* { ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} }, */

    /* placemouse options, choose which feels more natural:
    *    0 - tiled position is relative to mouse cursor
    *    1 - tiled position is relative to window center
    *    2 - mouse pointer warps to window center
    *
    * The moveorplace uses movemouse or placemouse depending on the floating state
    * of the selected client. Set up individual keybindings for the two if you want
    * to control these separately (i.e. to retain the feature to move a tiled window
    * into a floating position).
    */
    { ClkClientWin,         MODKEY,         Button1,        moveorplace,    {.i = 0} },
    { ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
    { ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
    { ClkClientWin,         ControlMask,    Button1,        dragmfact,      {0} },
    { ClkClientWin,         ControlMask,    Button3,        dragcfact,      {0} },
    { ClkTagBar,            0,              Button1,        view,           {0} },
    { ClkTagBar,            0,              Button3,        toggleview,     {0} },
    { ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
    { ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
    { ClkTabBar,            0,              Button1,        focuswin,       {0} },
    { ClkTabBar,            0,              Button1,        focuswin,       {0} },
    { ClkTabPrev,           0,              Button1,        movestack,      { .i = -1 } },
    { ClkTabNext,           0,              Button1,        movestack,      { .i = +1 } },
    { ClkTabClose,          0,              Button1,        killclient,     {0} },
};
