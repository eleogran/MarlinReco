*  
* $Id: tchain.inc,v 1.2 2008-06-26 09:35:56 aplin Exp $
*  
* $Log: not supported by cvs2svn $
* Revision 1.1.1.1  2005/07/11 15:15:48  aplin
* Initial version
*
* Revision 1.1.1.1  2005/06/18 10:05:35  gaede
* Initial local version
*
* Revision 1.1  2005/06/13 16:14:29  aplin
* *** empty log message ***
*
* Revision 1.1.1.1  2003/05/23 13:17:49  hvogt
* Brahms V308
*
*  

#include "padrow.inc"

      INTEGER MXHTCH,NPARCH,NHCHAI,IRCHAI,IHCHAI,MCHAIN,ISTCHA
      REAL PCHAIN,D2CHAI
      PARAMETER (MXHTCH=LTPDRO,NPARCH=23)
      COMMON /TCHAIN/NHCHAI,IRCHAI(MXHTCH),IHCHAI(MXHTCH),
     &              MCHAIN(MXHTCH),D2CHAI(MXHTCH),PCHAIN(NPARCH),ISTCHA

