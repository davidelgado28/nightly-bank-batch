       IDENTIFICATION DIVISION.
       PROGRAM-ID. RECONCIL.
      *
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CAD-SALDO ASSIGN TO "../data/cadsaldo.dat"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT CAD-TRANS ASSIGN TO "../data/cadtrans.dat"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT REL-ERRO  ASSIGN TO "../output/relerros.dat"
               ORGANIZATION IS LINE SEQUENTIAL.
      *
       DATA DIVISION.
       FILE SECTION.
       FD  CAD-SALDO.
       01  REG-SALDO.
           05 SLD-ID-CONTA     PIC X(05).
           05 SLD-NOME         PIC X(30).
           05 SLD-VALOR        PIC S9(09)V99.
      *
       FD  CAD-TRANS.
       01  REG-TRANS.
           05 TRN-ID-CONTA     PIC X(05).
           05 TRN-TIPO         PIC X(01).
           05 TRN-VALOR        PIC 9(07)V99.
      *
       FD  REL-ERRO.
       01  REG-ERRO.
           05 ERR-ID-CONTA     PIC X(05).
           05 ERR-MENSAGEM     PIC X(50).
           05 ERR-VALOR        PIC S9(09)V99.
      *
       WORKING-STORAGE SECTION.
       01  WS-EOF-SALDO        PIC X(01) VALUE 'N'.
       01  WS-EOF-TRANS        PIC X(01) VALUE 'N'.
       01  WS-CALC-SALDO       PIC S9(09)V99 VALUE 0.
       01  WS-CONTADORES.
           05 WS-QTD-LIDOS     PIC 9(05) VALUE 0.
           05 WS-QTD-ERROS     PIC 9(05) VALUE 0.
      *
       PROCEDURE DIVISION.
       INICIO-PROGRAMA.
           OPEN INPUT CAD-SALDO
                INPUT CAD-TRANS
                OUTPUT REL-ERRO.
           
           PERFORM LE-SALDO.
           PERFORM LE-TRANS.
      *
           PERFORM PROCESSA-LOTE 
               UNTIL WS-EOF-SALDO = 'S' AND WS-EOF-TRANS = 'S'.
      *
           CLOSE CAD-SALDO
                 CAD-TRANS
                 REL-ERRO.
           
           DISPLAY "========================================".
           DISPLAY " BATCH RECONCIL EXECUTION COMPLETED     ".
           DISPLAY " TOTAL ERRORS RECORDED: " WS-QTD-ERROS.
           DISPLAY "========================================".
           STOP RUN.
      *
       LE-SALDO.
           READ CAD-SALDO AT END
               MOVE 'S' TO WS-EOF-SALDO
               MOVE HIGH-VALUES TO SLD-ID-CONTA
           END-READ.
      *
       LE-TRANS.
           READ CAD-TRANS AT END
               MOVE 'S' TO WS-EOF-TRANS
               MOVE HIGH-VALUES TO TRN-ID-CONTA
           END-READ.
      *
       PROCESSA-LOTE.
           EVALUATE TRUE
               WHEN SLD-ID-CONTA < TRN-ID-CONTA
                   PERFORM LE-SALDO
               WHEN SLD-ID-CONTA > TRN-ID-CONTA
                   MOVE TRN-ID-CONTA TO ERR-ID-CONTA
                   MOVE "ACCOUNT NOT FOUND IN MASTER FILE" 
                       TO ERR-MENSAGEM
                   MOVE TRN-VALOR TO ERR-VALOR
                   WRITE REG-ERRO
                   ADD 1 TO WS-QTD-ERROS
                   PERFORM LE-TRANS
               WHEN OTHER
                   COMPUTE WS-CALC-SALDO = SLD-VALOR
                   EVALUATE TRN-TIPO
                       WHEN 'D'
                           SUBTRACT TRN-VALOR FROM WS-CALC-SALDO
                       WHEN 'C'
                           ADD TRN-VALOR TO WS-CALC-SALDO
                       WHEN OTHER
                           MOVE "INVALID TRANSACTION TYPE CODE" 
                               TO ERR-MENSAGEM
                   END-EVALUATE
                   
                   IF WS-CALC-SALDO < 0
                       MOVE SLD-ID-CONTA TO ERR-ID-CONTA
                       MOVE "INSUFFICIENT FUNDS FOR OPERATION" 
                           TO ERR-MENSAGEM
                       MOVE WS-CALC-SALDO TO ERR-VALOR
                       WRITE REG-ERRO
                       ADD 1 TO WS-QTD-ERROS
                   END-IF
                   
                   PERFORM LE-TRANS
           END-EVALUATE.
