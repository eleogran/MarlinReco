*  
* $Id: tkstor.F,v 1.5 2005-11-03 15:16:14 aplin Exp $
*  
* $Log: not supported by cvs2svn $
* Revision 1.4  2005/08/03 19:13:13  aplin
* corrected index of array when copying covariance matrix
*
* Revision 1.3  2005/07/21 16:37:00  aplin
* The itedat bank has been added with read and write interface.
*
* TKADDH has now been added so that the silicon hits are included as
* TE's.
*
* Added FSFSTR from delsearch to steer the creation of
* TS's
*
* The following include files need to be added for FSFSTR
* include/fsfdebug.inc
* include/fsfreject.inc
* include/fsfflags.inc
*
* FSFSTR is now called by TKTREV although all action is commented out.
*
* Revision 1.2  2005/07/20 17:46:38  aplin
* The itedat bank has been added with read and write interface. Though
* only the write function is used (tkstor). The read will have to be
* done through a statement function.
*
* Revision 1.1.1.1  2005/07/11 15:15:48  aplin
* Initial version
*
* Revision 1.1.1.1  2005/06/18 10:05:35  gaede
* Initial local version
*
* Revision 1.1  2005/06/13 16:14:19  aplin
* *** empty log message ***
*
* Revision 1.2  2004/07/22 15:21:03  aplin
* added tkfunc1.inc
*
* Revision 1.1.1.1  2003/05/23 13:17:51  hvogt
* Brahms V308
*
*  
      SUBROUTINE TKSTOR(CHTYPE,INDEX,DATA,N,LIST1,LIST2,IERR)
**********************************************************************
*
*     subroutine TKSTOR
*
*     store TE/TS/TK in tracking bank arrays
*
*     input:  CHTYPE - 'TE','TS', or 'TK' (upcase letters!)
*             DATA() - TE/TS/TK
*             N      - number of constituent hits (TE) or TEs (TS/TK)
*             LIST1()- array with identifiers of hits (TE) / TEs (TS/TK)
*             LIST2()- only used for 'TE': array with subdetector IDs of hits
*     output: INDEX  - position of Tx in Tx list
*             IERR   - 0 if successful
*                      1 if TK banks ran out of memory
*                      2 if too many hits (TE) / TEs (TS/TK) in list
*
*     Kristian Harder, September 1999
*
**********************************************************************
      IMPLICIT NONE
#include "include/bkgmode.inc"
#include "include/tkconst.inc"
#include "include/fkparm.inc"
#include "include/tkbank.inc"
#include "include/tkffread.inc"
#include "include/detnums.inc"
c#include "gcbank.inc"
      INTEGER     INDEX,N,IERR
      CHARACTER*2 CHTYPE
      INTEGER     LIST1(*),LIST2(*)
      REAL        DATA(*)

      INTEGER     MXTSTRK
      PARAMETER  (MXTSTRK=50)
      INTEGER     I,J,K,ITRK,NTSHIT,NTSTRK,NFVTX,NTVTX
      INTEGER     ITSTRK(MXTSTRK),NTSTKH(MXTSTRK)
      INTEGER     IFIRST,INUMBER

      integer IVAL(MXTSTRK)
      real    RVAL(MXTSTRK)
      real    cov(15)

      equivalence(IVAL,RVAL)

      integer try
      integer writetktecpp
      external writetktecpp  

      integer writetktkcpp
      external writetktkcpp  

      integer tkmktecpp
      external tkmktecpp
      
      integer tkmktkcpp
      external tkmktkcpp

      integer addhittktecpp
      external addhittktecpp

      integer addtetktkcpp
      external addtetktkcpp

      integer writetkitedatcpp
      external writetkitedatcpp

      integer writetkitkdatcpp
      external writetkitkdatcpp

      integer atest

#include "include/tkfunc1.inc"
#include "include/tkfunc.inc"
      IERR=0
      INDEX=0

      IF (CHTYPE.EQ.'TE') THEN


ccc      write(*,*)"DATA(",1,") = ",IVAL(1),"  subdetector ID"                         
ccc      write(*,*)"DATA(",2,") = ",IVAL(2),"  submodule code"                         
ccc      write(*,*)"DATA(",3,") = ",IVAL(3),"  reserved; must be zero"                 
ccc      write(*,*)"DATA(",4,") = ",IVAL(4),"  data measurement code"       
ccc      write(*,*)"DATA(",5,") = ",IVAL(5),"  pointer to the mass info"        
ccc      write(*,*)"DATA(",6,") = ",IVAL(6),"  charge"                                 
ccc      write(*,*)"DATA(",7,") = ",IVAL(7),"  NDF"          
ccc      write(*,*)"DATA(",8,") = ",DATA(8),"  chi^2"                                  
ccc      write(*,*)"DATA(",9,") = ",DATA(9),"  length of track element"                
ccc      write(*,*)"DATA(",10,") = ",DATA(10),"  x or R"                          
ccc      write(*,*)"DATA(",11,") = ",DATA(11),"  y or R*phi TE ref point" 
ccc      write(*,*)"DATA(",12,") = ",DATA(12),"  z"                          
ccc      write(*,*)"DATA(",13,") = ",DATA(13),"  theta angle"                            
ccc      write(*,*)"DATA(",14,") = ",DATA(14),"  phi angle"                             
ccc      write(*,*)"DATA(",15,") = ",DATA(15),"  1/p at reference point"                 
ccc      write(*,*)"DATA(",16,") = ",DATA(16),"  dE/dx (not yet)"         
ccc





c --- check range
        IF (NTE.GE.MXEVTE) THEN
          WRITE(6,*) 'TKSTOR: ERROR - TOO MANY TES. NEED MXEVTE>',NTE
          CALL TKVETO(1)
          IERR=1
          GOTO 999
        END IF
        IF (N.LT.0.OR.N+NHITTE.GT.NHMAX) THEN
          IF (N.GE.0) THEN
            WRITE(6,*) 'TKSTOR: TOO MANY HITS. NEED NHMAX>',N+NHITTE
            CALL TKVETO(1)
          ELSE
            WRITE(6,*) 'TKSTOR: NUMBER OF HITS LESS THAN ZERO.'
          END IF
          IERR=2
          GOTO 999
        END IF
c --- copy TE data
        NTE=NTE+1
        INDEX=NTE

C     Replace the original creation of this TE with the C++/F77 interface

C(KH)   CALL UCOPY(DATA,RTE(1,INDEX),MXTE)
c       CALL UCOPY(DATA,Q(LBRTE+MXTE*(INDEX-1)+1),MXTE)

      do i=1, 15
         cov(i) = DATA(i+16)
c         write(*,*) "DATA(",i+16") = " , DATA(i+16)
c         write(*,*) "cov(",i,") = " , cov(i)
      enddo

         try = tkmktecpp(DATA(1),DATA(2),DATA(3),DATA(4),
     +        DATA(5),DATA(6),DATA(7),DATA(8),DATA(9),DATA(10),
     +        DATA(11),DATA(12),DATA(13),DATA(14),DATA(15),DATA(16),
     +        cov)

c         do i=17, 32
c         try = writetktecpp(cov(i),i,INDEX)
c         enddo



c --- copy hit list and transform it into linear format if necessary
        DO I=1,N
           IF (LIST2(I).EQ.0) THEN
                                ! already linear format. copy without any index transformation

              try = addhittktecpp(LIST1(I),INDEX)

              IHITTE(NHITTE+I)=LIST1(I)
           ELSE IF (LIST2(I).GT.0.AND.LIST2(I).LE.3000) THEN
                                ! index relative to subdet. position -> transform index

              try = addhittktecpp(LIST1(I)+IHPOINT(LIST2(I))-1,INDEX)

              IHITTE(NHITTE+I)=LIST1(I)+IHPOINT(LIST2(I))-1
           ELSE
                                ! oops?
              WRITE(6,*) 'TKSTOR: BAD ENTRY IN LIST2(',I,'): ',LIST2(I)
              STOP
           END IF
        END DO

        try = writetkitedatcpp(NHITTE+1,1,INDEX)
        try = writetkitedatcpp(N,2,INDEX)
        try = writetkitedatcpp(0,3,INDEX)
        try = writetkitedatcpp(0,4,INDEX)

        RVAL(1) = DATA(1)

c         write(*,*) "TE added for: " , IVAL(1) ,
c     +       " with num of hits = ", ITEDAT(2, INDEX)

ccc**        ITEDAT(1,INDEX)=NHITTE+1
ccc**        ITEDAT(2,INDEX)=N
ccc**        ITEDAT(3,INDEX)=0
ccc**        ITEDAT(4,INDEX)=0
ccc        IQ(LBRT2+5*(INDEX-1)+1) = NHITTE + 1
ccc        IQ(LBRT2+5*(INDEX-1)+2) = N
ccc        IQ(LBRT2+5*(INDEX-1)+3) = 0
ccc        IQ(LBRT2+5*(INDEX-1)+4) = 0

        NHITTE=NHITTE+N


cccc --- calculate TE label
ccc        NTSTRK=0
ccc        DO I=1,MXTSTRK
ccc          ITSTRK(I)=0
ccc          NTSTKH(I)=0
ccc        END DO

ccc        ! loop over all hits
ccc        IFIRST=ITEDAT(1,INDEX)
ccc        INUMBER=N
ccc        DO I=IFIRST,IFIRST+INUMBER-1
ccc          ITRK=0
ccc          DO K=1,NTSTRK
ccc            IF (ITSTRK(K).EQ.IABS(ITKHIT(6,IHITTE(I)))) ITRK=K
ccc          END DO
ccc          IF (ITRK.EQ.0) THEN
ccc            NTSTRK=NTSTRK+1
ccc            IF (NTSTRK.GT.MXTSTRK) THEN
ccc              WRITE(6,*) 'ERROR IN TKSTOR: MXTSTRK TOO SMALL.'
ccc              CALL TKVETO(1)
ccc              NTSTRK=NTSTRK-1
ccc              NTSTKH(NTSTRK)=0
ccc            END IF
ccc            ITSTRK(NTSTRK)=IABS(ITKHIT(6,IHITTE(I)))
ccc            ITRK=NTSTRK
ccc          END IF
ccc          NTSTKH(ITRK)=NTSTKH(ITRK)+1
ccc        END DO


ccc        ! set label
ccc        IQ(LBRT2+5*(INDEX-1)+5) = 0
ccc**        ITEDAT(5,INDEX)=0
ccc        DO I=1,NTSTRK
ccc          IF (FLOAT(NTSTKH(I))/FLOAT(N).GE.0.90) THEN
ccc            IQ(LBRT2+5*(INDEX-1)+5) = ITSTRK(I)
ccc**            ITEDAT(5,INDEX)=ITSTRK(I)
ccc          ELSE IF (FLOAT(NTSTKH(I))/FLOAT(N).GE.0.70) THEN
ccc            IQ(LBRT2+5*(INDEX-1)+5) = -ITSTRK(I)
ccc**            ITEDAT(5,INDEX)=-ITSTRK(I)
ccc          END IF
ccc        END DO
ccc        ! debug output
ccc        IF (TKSTDBG.GT.1) THEN
ccc          WRITE(6,*) 'TKSTOR: TE composition analysis for TE ',INDEX
ccc          WRITE(6,*) '  detector ID ',ITE(1,INDEX)
ccc          DO I=1,NTSTRK
ccc            IF (ITSTRK(I).NE.0) THEN
ccc              WRITE(6,*) '  ',NTSTKH(I),' hits from track ',ITSTRK(I),
ccc     >             ' (GEANT ID ',ITKMCT(9,ITSTRK(I)),')'
ccc            ELSE
ccc              WRITE(6,*) '  ',NTSTKH(I),' noise hits'
ccc            END IF
ccc          END DO
ccc          WRITE(6,*) '  => label ',ITEDAT(5,INDEX)
ccc          WRITE(6,*) '  reference point ',RTE(10,INDEX),RTE(11,INDEX),
ccc     >                                    RTE(12,INDEX),ITE(1,INDEX),
ccc     >                                    IAND(ITE(1,INDEX),1)
ccc        END IF
ccc


      ELSE IF (CHTYPE.EQ.'TS') THEN

c --- check range
        IF (NTS.GE.NTSMX) THEN
          IERR=1
          GOTO 999
        END IF
        IF (N.LT.0.OR.N+NTSTEL.GT.NTSMX) THEN
          IERR=2
          GOTO 999
        END IF
c --- copy TS data
        NTS=NTS+1
        INDEX=NTS
        CALL UCOPY(DATA,RTS(1,INDEX),MXTS)
        CALL UCOPY(LIST1,ITSTEL(NTSTEL+1),N)
        ITSDAT(1,INDEX)=NTSTEL+1
        ITSDAT(2,INDEX)=N
        ITSDAT(3,INDEX)=0
        ITSDAT(4,INDEX)=0
        NTSTEL=NTSTEL+N

cccc --- calculate TS label
ccc        NTSHIT=0
ccc        NTSTRK=0
ccc        DO I=1,MXTSTRK
ccc          ITSTRK(I)=0
ccc          NTSTKH(I)=0
ccc        END DO
ccc        ! loop over all TEs
ccc        DO I=1,N
ccc          ! loop over all hits
ccc          IFIRST=ITEDAT(1,LIST1(I))
ccc          INUMBER=ITEDAT(2,LIST1(I))
ccc          DO J=IFIRST,IFIRST+INUMBER-1
ccc            NTSHIT=NTSHIT+1
ccc            ITRK=0
ccc            DO K=1,NTSTRK
ccc              IF (ITSTRK(K).EQ.IABS(ITKHIT(6,IHITTE(J)))) ITRK=K
ccc            END DO
ccc            IF (ITRK.EQ.0) THEN
ccc              NTSTRK=NTSTRK+1
ccc              IF (NTSTRK.GT.MXTSTRK) THEN
ccc                WRITE(6,*) 'FATAL ERROR IN TKSTOR: MXTSTRK TOO SMALL.'
ccc                NTSTRK=NTSTRK-1
ccc                CALL TKVETO(1)
ccc              END IF
ccc              ITSTRK(NTSTRK)=IABS(ITKHIT(6,IHITTE(J)))
ccc              ITRK=NTSTRK
ccc            END IF
ccc            NTSTKH(ITRK)=NTSTKH(ITRK)+1
ccc          END DO
ccc        END DO
ccc        ! set label
ccc        ITSDAT(5,INDEX)=0
ccc        DO I=1,NTSTRK
ccc          IF (FLOAT(NTSTKH(I))/FLOAT(NTSHIT).GE.0.90) THEN
ccc            ITSDAT(5,INDEX)=ITSTRK(I)
ccc          ELSE IF (FLOAT(NTSTKH(I))/FLOAT(NTSHIT).GE.0.70) THEN
ccc            ITSDAT(5,INDEX)=-ITSTRK(I)
ccc          END IF
ccc        END DO
ccc        ! check if majority of VTX hits agrees with overall label.
ccc        NTVTX=0
ccc        NFVTX=0
ccc        DO J=IFIRST,IFIRST+INUMBER-1
ccc          IF ((ITKHIT(5,IHITTE(J))/100.EQ.ID_VTX/100).OR.
ccc     >        (ITKHIT(5,IHITTE(J))/100.EQ.ID_VTXP/100)) THEN
ccc            IF (ITKHIT(6,IHITTE(J)).EQ.IABS(ITSDAT(5,INDEX))) THEN
ccc              NTVTX=NTVTX+1
ccc            ELSE
ccc              NFVTX=NFVTX+1
ccc            END IF
ccc          END IF
ccc        END DO
ccc        IF (NFVTX.GT.NTVTX) ITSDAT(5,INDEX)=ISIGN(ITSDAT(5,INDEX),-1)
ccc
        ! debug info
        IF (TKSTDBG.GT.1) THEN
          WRITE(6,*) 'TKSTOR: TS consists of the following tracks:'
          DO I=1,NTSTRK
            WRITE(6,*) '      ',ITSTRK(I),' (',NTSTKH(I),' HITS)'
          END DO
        END IF



      ELSE IF (CHTYPE.EQ.'TK') THEN


c --- check range
        IF (NTK.GE.NTKMX) THEN
          IERR=1
          GOTO 999
        END IF
        IF (N.LT.0.OR.N+NTKTEL.GT.NTKMX) THEN
          IERR=2
          GOTO 999
        END IF
c --- copy TK data
        NTK=NTK+1
        INDEX=NTK
        CALL UCOPY(DATA,RTK(1,INDEX),MXTK)
        CALL UCOPY(LIST1,ITKTEL(NTKTEL+1),N)
        ITKDAT(1,INDEX)=NTKTEL+1
        ITKDAT(2,INDEX)=N
        NTKTEL=NTKTEL+N

c       do i=1, 15
c          cov(i) = DATA(i+16)
c       enddo

c        write(*,*) "about to write a tk to LEPTRACKING"

c        try = tkmktkcpp(DATA(1),DATA(2),DATA(3),DATA(4),
c     +       DATA(5),DATA(6),DATA(7),DATA(8),DATA(9),DATA(10),
c     +       DATA(11),DATA(12),DATA(13),DATA(14),DATA(15),DATA(16),
c     +       DATA(17),DATA(18),DATA(19),DATA(20),DATA(21),DATA(22),
c     +       cov)



cccc --- calculate TK label
ccc        NTSHIT=0
ccc        NTSTRK=0
ccc        DO I=1,MXTSTRK
ccc          ITSTRK(I)=0
ccc          NTSTKH(I)=0
ccc        END DO
ccc        ! loop over all TEs
ccc        DO I=1,N
ccc          ! loop over all hits
ccc          IFIRST=ITEDAT(1,LIST1(I))
ccc          INUMBER=ITEDAT(2,LIST1(I))
ccc          DO J=IFIRST,IFIRST+INUMBER-1
ccc            NTSHIT=NTSHIT+1
ccc            ITRK=0
ccc            DO K=1,NTSTRK
ccc              IF (ITSTRK(K).EQ.IABS(ITKHIT(6,IHITTE(J)))) ITRK=K
ccc            END DO
ccc            IF (ITRK.EQ.0) THEN
ccc              NTSTRK=NTSTRK+1
ccc              IF (NTSTRK.GT.MXTSTRK) THEN
ccc                WRITE(6,*) 'FATAL ERROR IN TKSTOR: MXTSTRK TOO SMALL.'
ccc                NTSTRK=NTSTRK-1
ccc                CALL TKVETO(1)
ccc              END IF
ccc              ITSTRK(NTSTRK)=IABS(ITKHIT(6,IHITTE(J)))
ccc              ITRK=NTSTRK
ccc            END IF
ccc            NTSTKH(ITRK)=NTSTKH(ITRK)+1
ccc          END DO
ccc        END DO
ccc        ! set label
ccc        ITKDAT(3,INDEX)=0
ccc        DO I=1,NTSTRK
ccc          IF (FLOAT(NTSTKH(I))/FLOAT(NTSHIT).GE.0.90) THEN
ccc            ITKDAT(3,INDEX)=ITSTRK(I)
ccc          ELSE IF (FLOAT(NTSTKH(I))/FLOAT(NTSHIT).GE.0.70) THEN
ccc            ITKDAT(3,INDEX)=-ITSTRK(I)
ccc          END IF
ccc        END DO
ccc        ! check if majority of VTX hits agrees with overall label.
ccc        NTVTX=0
ccc        NFVTX=0
ccc        DO J=IFIRST,IFIRST+INUMBER-1
ccc          IF ((ITKHIT(5,IHITTE(J))/100.EQ.ID_VTX/100).OR.
ccc     >        (ITKHIT(5,IHITTE(J))/100.EQ.ID_VTXP/100)) THEN
ccc            IF (ITKHIT(6,IHITTE(J)).EQ.IABS(ITKDAT(3,INDEX))) THEN
ccc              NTVTX=NTVTX+1
ccc            ELSE
ccc              NFVTX=NFVTX+1
ccc            END IF
ccc          END IF
ccc        END DO
ccc        IF (NFVTX.GT.NTVTX) ITKDAT(3,INDEX)=ISIGN(ITKDAT(3,INDEX),-1)
ccc
      ELSE

        WRITE(6,*) 'TKSTOR: called with wrong argument'
        STOP

      END IF

 999  RETURN
      END


