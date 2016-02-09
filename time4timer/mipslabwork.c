/* mipslabwork.c

   This file written 2015 by F Lundevall

   This file should be changed by YOU! So add something here:

   This file modified 2015-12-24 by Ture Teknolog

   Latest update 2015-08-28 by F Lundevall

   For copyright and licensing, see file COPYING */

#include <stdint.h>   /* Declarations of uint_32 and the like */
#include <pic32mx.h>  /* Declarations of system-specific addresses etc */
#include "mipslab.h"  /* Declatations for these labs */

int mytime = 0x5957;
int timeoutcount = 0;

char textstring[] = "text, more text, and even more text!";

/* Interrupt Service Routine */
void user_isr( void )
{
  return;
}

/* Lab-specific initialization goes here */
void labinit( void )
{
  volatile int * trisE = (volatile int *) 0xbf886100;
  *trisE &= ~0xff;
  TRISD |= 0xFE0;
  // 1111 1110 0000

  T2CON = 0x0;
  T2CON = 0x70;
  TMR2 = 0x0;
  PR2 = (80000000/256)/10;
  IFS(0) = 0;
  return;
}

int timeout(){
  if(IFS(0)){
    IFS(0) = 0;
    timeoutcount++;
    return 1;
  }
  else
    return 0;
}

/* This function is called repetitively from the main program */
void labwork( void )
{
  T2CONSET=0x8000;
  static int count = 0;
  volatile int * portE = (volatile int *) 0xbf886110;
  *portE = count;
  int button = 0;
  int sw = 0;
  timeout();
  if(timeoutcount == 10){
    //delay( 1000 );
    time2string( textstring, mytime );
    display_string( 3, textstring );
    display_update();
    tick( &mytime );
    count++;
    timeoutcount = 0;
  }
  display_image(96, icon);
  button = getbtn();

  if(button){
    sw = getsw();
    if((button & 0x4))
      mytime = (mytime & 0x0fff) | (sw << 12);
    if((button & 0x2))
      mytime = (mytime & 0xf0ff) | (sw << 8);
    if((button & 0x1))
      mytime = (mytime & 0xff0f) | (sw << 4);
  }
}
