// Not usefull till shared variables are implemented (compute shaders)

R"(
#define M_PI 3.1415926535897932384626433832795


/* The unknown key */
const uvec4 E3T_KEY_UNKNOWN         = uvec4(0);

/* Printable keys */
const uvec4 E3T_KEY_SPACE           = uvec4(0,0,0,  1 << 0);
const uvec4 E3T_KEY_APOSTROPHE      = uvec4(0,0,0,  1 << 1); /* ' */
const uvec4 E3T_KEY_COMMA           = uvec4(0,0,0,  1 << 2); /* , */
const uvec4 E3T_KEY_MINUS           = uvec4(0,0,0,  1 << 3); /* - */
const uvec4 E3T_KEY_PERIOD          = uvec4(0,0,0,  1 << 4); /* . */
const uvec4 E3T_KEY_SLASH           = uvec4(0,0,0,  1 << 5); /* / */
const uvec4 E3T_KEY_0               = uvec4(0,0,0,  1 << 6);
const uvec4 E3T_KEY_1               = uvec4(0,0,0,  1 << 7);
const uvec4 E3T_KEY_2               = uvec4(0,0,0,  1 << 8);
const uvec4 E3T_KEY_3               = uvec4(0,0,0,  1 << 9);
const uvec4 E3T_KEY_4               = uvec4(0,0,0,  1 << 10);
const uvec4 E3T_KEY_5               = uvec4(0,0,0,  1 << 11);
const uvec4 E3T_KEY_6               = uvec4(0,0,0,  1 << 12);
const uvec4 E3T_KEY_7               = uvec4(0,0,0,  1 << 13);
const uvec4 E3T_KEY_8               = uvec4(0,0,0,  1 << 14);
const uvec4 E3T_KEY_9               = uvec4(0,0,0,  1 << 15);
const uvec4 E3T_KEY_SEMICOLON       = uvec4(0,0,0,  1 << 16); /* ; */
const uvec4 E3T_KEY_EQUAL           = uvec4(0,0,0,  1 << 17); /* = */
const uvec4 E3T_KEY_A               = uvec4(0,0,0,  1 << 18);
const uvec4 E3T_KEY_B               = uvec4(0,0,0,  1 << 19);
const uvec4 E3T_KEY_C               = uvec4(0,0,0,  1 << 20);
const uvec4 E3T_KEY_D               = uvec4(0,0,0,  1 << 21);
const uvec4 E3T_KEY_E               = uvec4(0,0,0,  1 << 22);
const uvec4 E3T_KEY_F               = uvec4(0,0,0,  1 << 23);
const uvec4 E3T_KEY_G               = uvec4(0,0,0,  1 << 24);
const uvec4 E3T_KEY_H               = uvec4(0,0,0,  1 << 25);
const uvec4 E3T_KEY_I               = uvec4(0,0,0,  1 << 26);
const uvec4 E3T_KEY_J               = uvec4(0,0,0,  1 << 27);
const uvec4 E3T_KEY_K               = uvec4(0,0,0,  1 << 28);
const uvec4 E3T_KEY_L               = uvec4(0,0,0,  1 << 29);
const uvec4 E3T_KEY_M               = uvec4(0,0,0,  1 << 30);
const uvec4 E3T_KEY_N               = uvec4(0,0,0,  1 << 31);
const uvec4 E3T_KEY_O               = uvec4(0,0,    1 << 1,0);
const uvec4 E3T_KEY_P               = uvec4(0,0,    1 << 2,0);
const uvec4 E3T_KEY_Q               = uvec4(0,0,    1 << 3,0);
const uvec4 E3T_KEY_R               = uvec4(0,0,    1 << 4,0);
const uvec4 E3T_KEY_S               = uvec4(0,0,    1 << 5,0);
const uvec4 E3T_KEY_T               = uvec4(0,0,    1 << 6,0);
const uvec4 E3T_KEY_U               = uvec4(0,0,    1 << 7,0);
const uvec4 E3T_KEY_V               = uvec4(0,0,    1 << 8,0);
const uvec4 E3T_KEY_W               = uvec4(0,0,    1 << 9,0);
const uvec4 E3T_KEY_X               = uvec4(0,0,    1 << 10,0);
const uvec4 E3T_KEY_Y               = uvec4(0,0,    1 << 11,0);
const uvec4 E3T_KEY_Z               = uvec4(0,0,    1 << 12,0);
const uvec4 E3T_KEY_LEFT_BRACKET    = uvec4(0,0,    1 << 13,0); /* [ */
const uvec4 E3T_KEY_BACKSLASH       = uvec4(0,0,    1 << 14,0); /* \ */
const uvec4 E3T_KEY_RIGHT_BRACKET   = uvec4(0,0,    1 << 15,0); /* ] */
const uvec4 E3T_KEY_GRAVE_ACCENT    = uvec4(0,0,    1 << 16,0); /* ` */
const uvec4 E3T_KEY_WORLD_1         = uvec4(0,0,    1 << 17,0); /* non-US #1 */
const uvec4 E3T_KEY_WORLD_2         = uvec4(0,0,    1 << 18,0); /* non-US #2 */

/* Function keys */
const uvec4 E3T_KEY_ESCAPE          = uvec4(0,0,    1 << 19,0);
const uvec4 E3T_KEY_ENTER           = uvec4(0,0,    1 << 20,0);
const uvec4 E3T_KEY_TAB             = uvec4(0,0,    1 << 21,0);
const uvec4 E3T_KEY_BACKSPACE       = uvec4(0,0,    1 << 22,0);
const uvec4 E3T_KEY_INSERT          = uvec4(0,0,    1 << 23,0);
const uvec4 E3T_KEY_DELETE          = uvec4(0,0,    1 << 24,0);
const uvec4 E3T_KEY_RIGHT           = uvec4(0,0,    1 << 25,0);
const uvec4 E3T_KEY_LEFT            = uvec4(0,0,    1 << 26,0);
const uvec4 E3T_KEY_DOWN            = uvec4(0,0,    1 << 27,0);
const uvec4 E3T_KEY_UP              = uvec4(0,0,    1 << 28,0);
const uvec4 E3T_KEY_PAGE_UP         = uvec4(0,0,    1 << 29,0);
const uvec4 E3T_KEY_PAGE_DOWN       = uvec4(0,0,    1 << 30,0);
const uvec4 E3T_KEY_HOME            = uvec4(0,0,    1 << 31,0);
const uvec4 E3T_KEY_END             = uvec4(0,      1 << 1,0,0);
const uvec4 E3T_KEY_CAPS_LOCK       = uvec4(0,      1 << 2,0,0);
const uvec4 E3T_KEY_SCROLL_LOCK     = uvec4(0,      1 << 3,0,0);
const uvec4 E3T_KEY_NUM_LOCK        = uvec4(0,      1 << 4,0,0);
const uvec4 E3T_KEY_PRINT_SCREEN    = uvec4(0,      1 << 5,0,0);
const uvec4 E3T_KEY_PAUSE           = uvec4(0,      1 << 6,0,0);
const uvec4 E3T_KEY_F1              = uvec4(0,      1 << 7,0,0);
const uvec4 E3T_KEY_F2              = uvec4(0,      1 << 8,0,0);
const uvec4 E3T_KEY_F3              = uvec4(0,      1 << 9,0,0);
const uvec4 E3T_KEY_F4              = uvec4(0,      1 << 10,0,0);
const uvec4 E3T_KEY_F5              = uvec4(0,      1 << 11,0,0);
const uvec4 E3T_KEY_F6              = uvec4(0,      1 << 12,0,0);
const uvec4 E3T_KEY_F7              = uvec4(0,      1 << 13,0,0);
const uvec4 E3T_KEY_F8              = uvec4(0,      1 << 14,0,0);
const uvec4 E3T_KEY_F9              = uvec4(0,      1 << 15,0,0);
const uvec4 E3T_KEY_F10             = uvec4(0,      1 << 16,0,0);
const uvec4 E3T_KEY_F11             = uvec4(0,      1 << 17,0,0);
const uvec4 E3T_KEY_F12             = uvec4(0,      1 << 18,0,0);
const uvec4 E3T_KEY_F13             = uvec4(0,      1 << 19,0,0);
const uvec4 E3T_KEY_F14             = uvec4(0,      1 << 20,0,0);
const uvec4 E3T_KEY_F15             = uvec4(0,      1 << 21,0,0);
const uvec4 E3T_KEY_F16             = uvec4(0,      1 << 22,0,0);
const uvec4 E3T_KEY_F17             = uvec4(0,      1 << 23,0,0);
const uvec4 E3T_KEY_F18             = uvec4(0,      1 << 24,0,0);
const uvec4 E3T_KEY_F19             = uvec4(0,      1 << 25,0,0);
const uvec4 E3T_KEY_F20             = uvec4(0,      1 << 26,0,0);
const uvec4 E3T_KEY_F21             = uvec4(0,      1 << 27,0,0);
const uvec4 E3T_KEY_F22             = uvec4(0,      1 << 28,0,0);
const uvec4 E3T_KEY_F23             = uvec4(0,      1 << 29,0,0);
const uvec4 E3T_KEY_F24             = uvec4(0,      1 << 30,0,0);
const uvec4 E3T_KEY_F25             = uvec4(0,      1 << 31,0,0);
const uvec4 E3T_KEY_KP_0            = uvec4(        1 << 1,0,0,0);
const uvec4 E3T_KEY_KP_1            = uvec4(        1 << 2,0,0,0);
const uvec4 E3T_KEY_KP_2            = uvec4(        1 << 3,0,0,0);
const uvec4 E3T_KEY_KP_3            = uvec4(        1 << 4,0,0,0);
const uvec4 E3T_KEY_KP_4            = uvec4(        1 << 5,0,0,0);
const uvec4 E3T_KEY_KP_5            = uvec4(        1 << 6,0,0,0);
const uvec4 E3T_KEY_KP_6            = uvec4(        1 << 7,0,0,0);
const uvec4 E3T_KEY_KP_7            = uvec4(        1 << 8,0,0,0);
const uvec4 E3T_KEY_KP_8            = uvec4(        1 << 9,0,0,0);
const uvec4 E3T_KEY_KP_9            = uvec4(        1 << 10,0,0,0);
const uvec4 E3T_KEY_KP_DECIMAL      = uvec4(        1 << 11,0,0,0);
const uvec4 E3T_KEY_KP_DIVIDE       = uvec4(        1 << 12,0,0,0);
const uvec4 E3T_KEY_KP_MULTIPLY     = uvec4(        1 << 13,0,0,0);
const uvec4 E3T_KEY_KP_SUBTRACT     = uvec4(        1 << 14,0,0,0);
const uvec4 E3T_KEY_KP_ADD          = uvec4(        1 << 15,0,0,0);
const uvec4 E3T_KEY_KP_ENTER        = uvec4(        1 << 16,0,0,0);
const uvec4 E3T_KEY_KP_EQUAL        = uvec4(        1 << 17,0,0,0);
const uvec4 E3T_KEY_LEFT_SHIFT      = uvec4(        1 << 18,0,0,0);
const uvec4 E3T_KEY_LEFT_CONTROL    = uvec4(        1 << 19,0,0,0);
const uvec4 E3T_KEY_LEFT_ALT        = uvec4(        1 << 20,0,0,0);
const uvec4 E3T_KEY_LEFT_SUPER      = uvec4(        1 << 21,0,0,0);
const uvec4 E3T_KEY_RIGHT_SHIFT     = uvec4(        1 << 22,0,0,0);
const uvec4 E3T_KEY_RIGHT_CONTROL   = uvec4(        1 << 23,0,0,0);
const uvec4 E3T_KEY_RIGHT_ALT       = uvec4(        1 << 24,0,0,0);
const uvec4 E3T_KEY_RIGHT_SUPER     = uvec4(        1 << 25,0,0,0);
const uvec4 E3T_KEY_MENU            = uvec4(        1 << 26,0,0,0);

const uvec4 E3T_KEY_LAST            = uvec4(        1 << 26,0,0,0);
)"