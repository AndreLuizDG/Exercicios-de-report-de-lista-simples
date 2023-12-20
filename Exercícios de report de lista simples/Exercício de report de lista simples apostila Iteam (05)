 REPORT Z_ALGJ_29.

*--------------------------------------------------------------------------------------*
*5 - Elaborar um programa ABAP onde deverá ser criada uma tela de seleção com
* o Nº conta do Razão como seleção múltipla. Seu tipo se encontra na tabela SKA1.
*   Selecionar na tabela SKA1 todas as Contas do Razão que estiverem de acordo
* com o campo Nº conta do Razão da tela de seleção e que pertençam ao Plano de
* Contas ‘INT’, retornando os campos Nº conta do Razão e Data de criação do registro.
*   Para cada registro encontrado na tabela SKA1, selecionar na tabela SKB1 as
* empresas correspondentes as Contas do Razão encontradas onde o campo Nº conta do
* Razão relaciona as duas tabelas, retornando os campos Empresa e Nº conta do Razão.
*   Para cada registro encontrado na tabela SKB1, selecionar na tabela T001 os
* dados das empresas selecionadas, onde o campo Empresa relaciona as duas tabelas e
* o País seja igual a ‘BR’, retornando os campos Empresa e Denominação da firma ou
* empresa.
*   Para cada registro retornado da tabela SKA1, selecionar na tabela SKAT sua
* descrição desde que esta esteja no Código de idioma ‘PT’, Plano de Contas ‘INT’, onde
* o campo Nº conta do Razão relaciona as duas tabelas, retornando os campos Nº conta
* do Razão e Texto das contas do Razão.
*   O relatório deve imprimir todas as contas do razão de cada empresa selecionada
* do País ‘BR’, bem como os dados da empresa e a descrição da conta do razão no
* Código de idioma ‘PT’. Para cada empresa deverá mostrar um contador de contas do
* razão e no final do relatório a quantidade de registros encontrados.
*   Imprimir os campos: Empresa, Denominação da firma ou empresa, Nº conta do
* Razão, Data de criação do registro e Texto das contas do Razão.
*--------------------------------------------------------------------------------------*
 TABLES:
   SKA1.

 TYPES:

   BEGIN OF TYPE_SKA1,
     KTOPL TYPE SKA1-KTOPL,  "Plano de contas
     SAKNR TYPE SKA1-SAKNR,  "Nº conta do Razão
     ERDAT TYPE SKA1-ERDAT,  "Data de criação do registro
   END OF TYPE_SKA1,

   BEGIN OF TYPE_SKB1,
     BUKRS TYPE SKB1-BUKRS, "Empresa
     SAKNR TYPE SKB1-SAKNR, "Nº conta do Razão
   END OF TYPE_SKB1,

   BEGIN OF TYPE_T001,
     BUKRS TYPE T001-BUKRS,  "Empresa
     BUTXT TYPE T001-BUTXT,  "Denominação da firma ou empresa
     LAND1 TYPE T001-LAND1,  "Chave do país
   END OF TYPE_T001,

   BEGIN OF TYPE_SKAT,
     SPRAS TYPE SKAT-SPRAS,  "Código de idioma
     KTOPL TYPE SKAT-KTOPL,  "Plano de contas
     SAKNR TYPE SKAT-SAKNR,  "Nº conta do Razão
     TXT20 TYPE SKAT-TXT20,  "Texto das contas do Razão
   END OF TYPE_SKAT.

 DATA:
   TI_SKA1 TYPE TABLE OF TYPE_SKA1,
   TI_SKB1 TYPE TABLE OF TYPE_SKB1,
   TI_T001 TYPE TABLE OF TYPE_T001,
   TI_SKAT TYPE TABLE OF TYPE_SKAT.

 DATA:
   WA_SKA1 TYPE TYPE_SKA1,
   WA_SKB1 TYPE TYPE_SKB1,
   WA_T001 TYPE TYPE_T001,
   WA_SKAT TYPE TYPE_SKAT.

 DATA:
   V_EMPRESA    TYPE SKB1-BUKRS,
   V_CONTADOR   TYPE I,
   V_CONTADOR_2 TYPE I.

 SELECTION-SCREEN: BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.

 SELECT-OPTIONS S_SAKNR FOR SKA1-SAKNR.

 SELECTION-SCREEN: END OF BLOCK B1.

 FREE TI_SKA1.
 SELECT KTOPL  "Plano de contas
        SAKNR  "Nº conta do Razão
        ERDAT  "Data de criação do registro
 FROM SKA1
 INTO TABLE TI_SKA1
 WHERE SAKNR IN S_SAKNR
   AND KTOPL = 'INT'.

 IF SY-SUBRC <> 0.
   FREE TI_SKA1.
   MESSAGE 'Dados não encontrados!' TYPE 'S' DISPLAY LIKE 'S'.
   LEAVE LIST-PROCESSING.
 ENDIF.

 IF TI_SKA1 IS NOT INITIAL.

   FREE TI_SKB1.
   SELECT BUKRS  "Empresa
          SAKNR  "Nº conta do Razão
     FROM SKB1
     INTO TABLE TI_SKB1
      FOR ALL ENTRIES IN TI_SKA1
    WHERE SAKNR = TI_SKA1-SAKNR.

   IF SY-SUBRC <> 0.
     FREE TI_SKB1.
   ENDIF.

 ENDIF.

 IF TI_SKB1 IS NOT INITIAL.

   FREE TI_T001.
   SELECT BUKRS  "Empresa
          BUTXT  "Denominação da firma ou empresa
          LAND1  "Chave do país
     FROM T001
     INTO TABLE TI_T001
      FOR ALL ENTRIES IN TI_SKB1
    WHERE BUKRS = TI_SKB1-BUKRS
      AND LAND1 = 'BR'.

   IF SY-SUBRC <> 0.
     FREE TI_T001.
   ENDIF.

 ENDIF.

 IF TI_SKA1 IS NOT INITIAL.

   FREE TI_SKAT.
   SELECT SPRAS  "Código de idioma
          KTOPL  "Plano de contas
          SAKNR  "Nº conta do Razão
          TXT20  "Texto das contas do Razão
     FROM SKAT
     INTO TABLE TI_SKAT
      FOR ALL ENTRIES IN TI_SKA1
    WHERE SPRAS = 'PT'
      AND KTOPL = 'INT'
      AND SAKNR = TI_SKA1-SAKNR.

   IF SY-SUBRC <> 0.
     FREE TI_SKAT.
   ENDIF.

 ENDIF.

 SORT: TI_SKA1 BY SAKNR,
       TI_SKB1 BY SAKNR
                  BUKRS,
       TI_T001 BY BUKRS,
       TI_SKAT BY SAKNR.

 LOOP AT TI_SKA1 INTO WA_SKA1.

   CLEAR WA_SKB1.
   READ TABLE TI_SKB1 INTO WA_SKB1 WITH KEY
                                   SAKNR = WA_SKA1-SAKNR BINARY SEARCH.

   CLEAR WA_T001.
   READ TABLE TI_T001 INTO WA_T001 WITH KEY
                                   BUKRS = WA_SKB1-BUKRS BINARY SEARCH.

   CLEAR WA_SKAT.
   READ TABLE TI_SKAT INTO WA_SKAT WITH KEY
                                   SAKNR = WA_SKA1-SAKNR BINARY SEARCH.

*O relatório deve imprimir todas as contas do razão de cada empresa selecionada do País ‘BR’
*bem como os dados da empresa e a descrição da conta do razão no Código de idioma ‘PT’.
*Para cada empresa deverá mostrar um contador de contas do razão e no final do relatório a quantidade de registros encontrados.

   IF V_EMPRESA <> WA_SKB1-BUKRS.

     IF V_EMPRESA IS NOT INITIAL.
       FORMAT RESET.
       FORMAT COLOR COL_TOTAL INTENSIFIED OFF.

       WRITE:
           /1   '|', 'Total de contas do razão para a empresa ', WA_SKB1-BUKRS, ' =', V_CONTADOR_2,
           90   '|'.
     ENDIF. "IF V_EMPRESA IS NOT INITIAL.

     CLEAR: V_CONTADOR_2.

     FORMAT RESET.
     FORMAT COLOR COL_HEADING INTENSIFIED OFF.

     WRITE:
         /1   '|', 'Empresa',
         30   '|', 'Denominação da firma ou empresa',
         90   '|'.

     FORMAT RESET.
     FORMAT COLOR COL_POSITIVE INTENSIFIED OFF.

     WRITE:
        /1   '|', WA_SKB1-BUKRS, "Empresa
        30   '|', WA_T001-BUTXT, "Denominação da firma ou empresa
        90   '|'.


     FORMAT RESET.
     FORMAT COLOR COL_HEADING INTENSIFIED OFF.

     WRITE:
         /1   '|', 'Nº conta do Razão',
         30   '|', 'Data de criação do registro',
         60   '|', 'Texto das contas do Razão',
         90   '|'.

     V_EMPRESA = WA_SKB1-BUKRS.

   ENDIF. "IF V_EMPRESA <> WA_SKB1-BUKRS.

   FORMAT RESET.
   FORMAT COLOR COL_POSITIVE INTENSIFIED OFF.

   WRITE:
       /1   '|', WA_SKA1-SAKNR, "Nº conta do Razão
       30   '|', WA_SKA1-ERDAT, "Data de criação do registro
       60   '|', WA_SKAT-TXT20, "Texto das contas do Razão
       90   '|'.


   FORMAT RESET.
   FORMAT COLOR COL_TOTAL INTENSIFIED OFF.

   V_CONTADOR_2 = V_CONTADOR_2 + 1.
   V_CONTADOR = V_CONTADOR + 1.

 ENDLOOP.

 FORMAT RESET.
 FORMAT COLOR COL_TOTAL INTENSIFIED OFF.

 WRITE:
     /1   '|', 'Total de contas do razão para a empresa ', WA_SKB1-BUKRS, ' =', V_CONTADOR_2,
     90   '|'.

 WRITE:
     /1   '|', 'Total de registros selecionados =', V_CONTADOR,
     90   '|'.
