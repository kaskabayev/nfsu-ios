/* game_profile.h (NFSU1) -- what differs between the games in src/main.c and
 * src/ios_launcher.m. One file per game. CMake puts games/<game>/ on the
 * include path (-DNFSU_GAME=nfsu1). */
#ifndef NFSU_GAME_PROFILE_H
#define NFSU_GAME_PROFILE_H

#define NFSU_GAME_NFSU2 0
#define NFSU_GAME_NFSU1 1

/* Names. The id prefixes log lines and the files in Documents. */
#define NFSU_GAME_ID        "nfsu1"
#define NFSU_SHORT_NAME     "NFSU1"
#define NFSU_LONG_NAME      "Need for Speed: Underground"
#define NFSU_ISO_NAME       "NFSU1.iso"

/* Files in Documents. A *_LEGACY name is the one older builds used: it is
 * read when the new file does not exist. NFSU1 builds up to u1-5 used the
 * NFSU2 names. NULL = never renamed. The layout file
 * <id>_touch_layout_<phone|pad>.txt follows the same rule (xbox_app_id,
 * xbox_app_legacy_id). */
#define NFSU_GAME_ID_LEGACY         "nfsu2"
#define NFSU_LOG_FILE               "nfsu1_log.txt"
#define NFSU_SETTINGS_FILE          "nfsu1_env.txt"
#define NFSU_SETTINGS_FILE_LEGACY   "nfsu2_env.txt"

/* Folders people copy the game into (iOS), probed in this order after the
 * plain game dir. */
#define NFSU_IOS_DATA_FOLDERS       { "NFSU1-data", "game", "nfsu1", "NFSU1" }

/* Launch screen and log banner. */
#define NFSU_BUILD_TAG      "u1-7"
#define NFSU_BUILD_NOTE     "u1-6 + upstream 0.5.13 merged: lifter fixes"

/* The disc this build expects. These values belong to the gen/ the binary was
 * built from (the XBE the lifter read), so they must change together with it:
 * NTSC-U, default.xbe certificate title ID 0x45410047, certificate version
 * 0x00000001. */
#define NFSU_XBE_TITLE_ID   0x45410047u
#define NFSU_XBE_VERSION    0x00000001u
#define NFSU_XBE_SHA256 \
    "cdd562ffcc70906b3fecd841db4dc10fd463664b05e03f896a8fb38b9a7d878a"
#define NFSU_ENTRY_POINT    0x00164356u

/* Settings whose default differs from the shared one: { env key, value },
 * ends with { NULL, NULL }. main.c sets each as an environment default, and
 * the settings panels show the same default (xbox_app_default_on). NFSU1:
 * 4:3 and no movie crop until both are checked for this title; the
 * upstream 0.5.13 renderer paths (bulk pushbuffer runs, per-axis vertex snap)
 * stay off until they are checked here. */
#define NFSU_ENV_DEFAULTS \
    { { "RECOMP_WIDESCREEN", "0" }, { "NFSU2_MOVIE_CROP", "0" }, \
      { "RECOMP_PB_RUN", "0" }, { "RECOMP_VK_SNAP", "0" }, { NULL, NULL } }

/* Hooks the title has. NFSU1's image has no .data float at 0x3A4C64 (outside
 * the image), and NFSU2's string-table patch does not apply. */
#define NFSU_HAS_SIM_STEP_CAP   0
#define NFSU_HAS_TEXT_PATCH     0
#define NFSU_HAS_OPTIONS        0   /* nfsu2x_options.txt + Options > Video/Audio/Gameplay rows */

#endif /* NFSU_GAME_PROFILE_H */
