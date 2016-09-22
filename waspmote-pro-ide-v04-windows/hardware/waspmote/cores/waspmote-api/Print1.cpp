#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "wiring.h"
#include "Print1.h"


// Public Methods //////////////////////////////////////////////////////////////

/* default implementation: may be overridden */
size_t Print1::write(const uint8_t *buffer, size_t size)
{	
  size_t n = 0;
  while (size--) {
    if (write(*buffer++)) {
		n++;
	}
    else {
		//break;
	}
  }
  return n;
}

size_t Print1::print(const __FlashStringHelper *ifsh)
{
  PGM_P p = reinterpret_cast<PGM_P>(ifsh);
  size_t n = 0;
  while (1) {
    unsigned char c = pgm_read_byte(p++);
    if (c == 0) break;
    if (write(c)) n++;
    else break;
  }
  return n;
}

size_t Print1::print(const String &s)
{
  return write(s.c_str(), s.length());
}

size_t Print1::print(const char str[])
{
  return write(str);
}

size_t Print1::print(char c)
{
  return write(c);
}

size_t Print1::print(unsigned char b, int base)
{
  return print((unsigned long) b, base);
}

size_t Print1::print(int n, int base)
{
  return print((long) n, base);
}

size_t Print1::print(unsigned int n, int base)
{
  return print((unsigned long) n, base);
}

size_t Print1::print(long n, int base)
{
  if (base == 0) {
    return write(n);
  } else if (base == 10) {
    if (n < 0) {
      int t = print('-');
      n = -n;
      return printNumber(n, 10) + t;
    }
    return printNumber(n, 10);
  } else {
    return printNumber(n, base);
  }
}

size_t Print1::print(unsigned long n, int base)
{
  if (base == 0) return write(n);
  else return printNumber(n, base);
}

size_t Print1::print(double n, int digits)
{	
  return printFloat(n, digits);
}

size_t Print1::println(const __FlashStringHelper *ifsh)
{
  size_t n = print(ifsh);
  n += println();
  return n;
}

size_t Print1::print(const Printable1& x)
{
  return x.printTo(*this);
}

size_t Print1::println(void)
{
  return write("\r\n");
}

size_t Print1::println(const String &s)
{
  size_t n = print(s);
  n += println();
  return n;
}

size_t Print1::println(const char c[])
{
  size_t n = print(c);
  n += println();
  return n;
}

size_t Print1::println(char c)
{
  size_t n = print(c);
  n += println();
  return n;
}

size_t Print1::println(unsigned char b, int base)
{
  size_t n = print(b, base);
  n += println();
  return n;
}

size_t Print1::println(int num, int base)
{
  size_t n = print(num, base);
  n += println();
  return n;
}

size_t Print1::println(unsigned int num, int base)
{
  size_t n = print(num, base);
  n += println();
  return n;
}

size_t Print1::println(long num, int base)
{
  size_t n = print(num, base);
  n += println();
  return n;
}

size_t Print1::println(unsigned long num, int base)
{
  size_t n = print(num, base);
  n += println();
  return n;
}

size_t Print1::println(double num, int digits)
{
  size_t n = print(num, digits);
  n += println();
  return n;
}

size_t Print1::println(const Printable1& x)
{
  size_t n = print(x);
  n += println();
  return n;
}

// Private Methods /////////////////////////////////////////////////////////////

size_t Print1::printNumber(unsigned long n, uint8_t base)
{

  char buf[8 * sizeof(long) + 1]; // Assumes 8-bit chars plus zero byte.
  char *str = &buf[sizeof(buf) - 1];

  *str = '\0';

  // prevent crash if called with base == 1
  if (base < 2) base = 10;

  do {
    char c = n % base;
    n /= base;

    *--str = c < 10 ? c + '0' : c + 'A' - 10;
  } while(n);
  
  return write(str);
}

size_t Print1::printFloat(double number, uint8_t digits) 
{ 

  size_t n = 0;
  digits = 4;
  
  if (isnan(number)) return print("nan");
  if (isinf(number)) return print("inf");
  if (number > 4294967040.0) return print ("ovf");  // constant determined empirically
  if (number <-4294967040.0) return print ("ovf");  // constant determined empirically
  
  // Handle negative numbers
  if (number < 0.0)
  {
     n += print('-');
     number = -number;
  }

  // Round correctly so that print(1.999, 2) prints as "2.00"
  double rounding = 0.5;
  for (uint8_t i=0; i<digits; ++i)
    rounding /= 10.0;
  
  number += rounding;

  // Extract the integer part of the number and print it
  //unsigned int 
  unsigned int int_part = (unsigned int)number;
  double remainder = number - (double)int_part;
  
  
  n += print(int_part);

  // Print1 the decimal point, but only if there are digits beyond
  
  if (digits > 0) {
    n += print("."); 
  }

  // Extract digits from the remainder one at a time
  while (digits-- > 0)
  {
    remainder *= 10.0;
    int toPrint = int(remainder);
    n += print(toPrint);
    remainder -= toPrint; 
  } 
  
  return n;
}