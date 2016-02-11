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
int prime = 1234567;

char textstring[] = "text, more text, and even more text!";

/* Interrupt Service Routine */
void user_isr( void )
{
  if(IFS(0) & 0x100){
    IFS(0) &= ~0x100;
    if(timeoutcount == 10){
      timeoutcount = 0;
      time2string(textstring,mytime);
      display_string(3, textstring);
      display_update();
      tick(&mytime);
    }
    else timeoutcount++;
  }
  if(IFS(0) & 0x80) {
    IFS(0) &= ~0x80;
    PORTE += 1;
  }
  return;
}

/* Lab-specific initialization goes here */
void labinit( void )
{
  volatile int * trisE = (volatile int *) 0xbf886100;
  *trisE &= ~0xff;
  TRISD |= 0xFE0;
  // 1111 1110 0000
  PORTE = 0x0;


  // Configure timer2 to give 10 interrupt per second
  const int interruptsPerSecond = 10;
  T2CON = 0x0;
  T2CON = 0x70;
  TMR2 = 0x0;
  PR2 = (80000000/256)/interruptsPerSecond;
  T2CONSET = 0x8000;


  IPC(2) = 0x1f;    // Priority, probably skippable
  IEC(0) = 0x100;   /// Enable Timer 2, bit 8 of IEC0
  // 011111
  IFS(0) = 0;        // Reset all interupt fl ags to zero

  IEC(0) |= 0x80;
  IPC(1) |= 0x1f000000;

  //__use_isr_install();  // KTH-lab code, will call a method named "user_isr()"
  enable_interrupt();


  return;
}

int timeout(){
  if(IFS(0) & 0x100){
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
  prime = nextprime(prime);

  display_string(0,itoaconv(prime));
  display_update();
  //display_debug(0xbf8810b0);
}
