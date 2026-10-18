/* game_profile.h (NFSU2) -- what differs between the games in src/main.c and
 * src/ios_launcher.m. One file per game. CMake puts games/<game>/ on the
 * include path (-DNFSU_GAME=nfsu2). */
#ifndef NFSU_GAME_PROFILE_H
#define NFSU_GAME_PROFILE_H

#define NFSU_GAME_NFSU2 1
#define NFSU_GAME_NFSU1 0

/* Names. The id prefixes log lines and the files in Documents. */
#define NFSU_GAME_ID        "nfsu2"
#define NFSU_SHORT_NAME     "NFSU2"
#define NFSU_LONG_NAME      "Need for Speed: Underground 2"
#define NFSU_ISO_NAME       "NFSU2.iso"

/* Files in Documents. A *_LEGACY name is the one older builds used: it is
 * read when the new file does not exist. NULL = never renamed. The layout
 * file <id>_touch_layout_<phone|pad>.txt follows the same rule (xbox_app_id,
 * xbox_app_legacy_id). */
#define NFSU_GAME_ID_LEGACY         NULL
#define NFSU_LOG_FILE               "nfsu2_log.txt"
#define NFSU_SETTINGS_FILE          "nfsu2_env.txt"
#define NFSU_SETTINGS_FILE_LEGACY   NULL

/* Folders people copy the game into (iOS), probed in this order after the
 * plain game dir. */
#define NFSU_IOS_DATA_FOLDERS       { "NFSU2-data", "game", "nfsu2", "NFSU2" }

/* Launch screen and log banner. */
#define NFSU_BUILD_TAG      "v34"
#define NFSU_BUILD_NOTE     "v33 + upstream 0.5.13 merged: lifter fixes, present semaphores"

/* The disc this build expects. These values belong to the gen/ the binary was
 * built from (the XBE the lifter read), so they must change together with it:
 * NTSC-U, default.xbe certificate title ID 0x4541005A, certificate version
 * 0x00000001. */
#define NFSU_XBE_TITLE_ID   0x4541005Au
#define NFSU_XBE_VERSION    0x00000001u
#define NFSU_XBE_SHA256 \
    "95c22b9c594f0c187f602ac6484fe4cb65a9d53dafe3110ed815598eb9dcb0bd"
#define NFSU_ENTRY_POINT    0x0021B1CEu

/* Settings whose default differs from the shared one: { env key, value },
 * ends with { NULL, NULL }. main.c sets each as an environment default, and
 * the settings panels show the same default (xbox_app_default_on). NFSU2 has
 * none. */
#define NFSU_ENV_DEFAULTS           { { NULL, NULL } }

/* Hooks the title has. */
#define NFSU_HAS_SIM_STEP_CAP   1   /* 1/60 s cap in .data, patched at boot */
#define NFSU_SIM_STEP_CAP_VA    0x3A4C64u
#define NFSU_HAS_TEXT_PATCH     1   /* string-table patch (text_patch.c) */
#define NFSU_HAS_OPTIONS        1   /* nfsu2x_options.txt + Options > Video/Audio/Gameplay rows */

#endif /* NFSU_GAME_PROFILE_H */
