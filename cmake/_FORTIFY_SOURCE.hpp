#ifndef _FORTIFY_SOURCE_HPP
#define _FORTIFY_SOURCE_HPP
#ifdef _FORTIFY_SOURCE
    #if _FORTIFY_SOURCE < 3
        #undef _FORTIFY_SOURCE
        #define _FORTIFY_SOURCE 3
    #endif
#else
    #define _FORTIFY_SOURCE 3
#endif

#endif /* _FORTIFY_SOURCE_HPP */
