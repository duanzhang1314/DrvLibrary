/*******************************************************************************
 * The <types.h> header contains important data type definitions.
 * It is considered good programming practice to use these definitions,
 * instead of the underlying base type. By convention, all type names begin
 * with T_.
*******************************************************************************/

#ifndef __TYPES_H__
#define __TYPES_H__

/*******************************************************************************
 *   
 *
*******************************************************************************/

/*******************************************************************************
#ifdef  OS_GLOBALS
#define OS_EXTERN
#else
#define OS_EXTERN  extern
#endif
*******************************************************************************/

/*******************************************************************************
 *                                DATA TYPES
 *                           (Compiler Specific)
*******************************************************************************/
typedef unsigned char   T_BOOL;
typedef unsigned char   T_U8;       /* Unsigned  8 bit quantity               */
typedef signed   char   T_S8;       /* Signed    8 bit quantity               */
typedef unsigned short  T_U16;      /* Unsigned 16 bit quantity               */
typedef signed   short  T_S16;      /* Signed   16 bit quantity               */
typedef unsigned long   T_U32;      /* Unsigned 32 bit quantity               */
typedef signed   long   T_S32;      /* Signed   32 bit quantity               */

typedef float           T_F32;      /* Single precision floating point        */
typedef double          T_F64;      /* Double precision floating point        */



#ifndef  NULL
#if !defined(__cplusplus)
#define	NULL	          ((void *)0)
#else
#define	NULL	          0
#endif                              /* !defined(__cplusplus)                  */
#endif


#define EXTERN          extern      /* Used in *.h files                      */
#define PRIVATE         static      /* PRIVATE x limits the scope of x        */
#define PUBLIC			            /* PUBLIC is the opposite of PRIVATE      */

#define TRUE            1           /* Used for turning integer into boolean  */
#define FALSE           0           /* Used for turning integer into boolean  */

#define MAX(a, b)       ((a) > (b) ? (a) : (b))
#define MIN(a, b)       ((a) < (b) ? (a) : (b))
#define ABS(a)          ((a) < 0 ? -(a) : (a))

#define MASK(__bf)                  (((1U << ((be##__bf)-(bs##__bf) + \
                                    1)) - 1U) << (bs##__bf))
#define SETS(__dst, __bf, __val)    ((dst) = (((dst)&~(MASK(__bf))) | \
                                    (((val)<<(bs##__bf))&(MASK(__bf)))))
#define GETS(__src, __bf)           (((src)&(MASK(__bf))) >> (bs##__bf))

typedef struct {
    T_U16 m_pt_x;
    T_U16 m_pt_y;
} T_sPOINT;

typedef struct {
    T_U8  m_tm_sec;                 /* seconds after the minute [0, 59]       */
    T_U8  m_tm_min;                 /* minutes after the hour [0, 59]         */
    T_U8  m_tm_hour;                /* hours since midnight [0, 23]           */
    T_U8  m_tm_day;                 /* day of the month [1, 31]               */
    T_U8  m_tm_mon;                 /* month of the year [1, 12]              */
    T_U8  m_tm_year;                /* years since 1900                       */
    T_U8  m_tm_week;                /* day of the week [1, 7]                 */
    T_U8  m_tm_yweek;               /* weeks of the year [1, 52]              */
    T_U16 m_tm_yday;                /* days since January 1 [0, 365]          */
} T_sTIME;

#endif //__TYPES_H__
