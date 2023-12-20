REPORT z_algj_28.

*----------------------------------------------------------------------------*
*4 - Elaborar um programa ABAP onde deverá ser criada uma tela de seleção com
* o campo Centro como seleção múltipla e o campo Chave do calendário de fábrica
* como seleção única com o valor default ‘BR’. Os tipos dos campos podem ser
* encontrados na tabela T001W.
*   Selecionar na tabela T001W todos os Centros que estiverem de acordo com o
* campo Centro da tela de seleção e que também estejam de acordo com o campo
* Chave do calendário de fábrica da tela de seleção, retornando os campos
* Centro, Nome 1, País e Região.
*   Para cada Centro encontrado na tabela T001W, selecionar na tabela MARC os
* materiais que foram ampliados para este centro onde o campo Centro relaciona
* as duas tabelas, retornando os campos Nº do material e Centro.
* Para cada Nº do material encontrado na tabela MARC, selecionar na tabela MAKT
* sua Denominação desde que estejam no Idioma ‘PT’.
* O campo Nº do material relaciona as duas tabelas, retornando os campos Nº do
* material e Denominação.
*   O relatório deverá imprimir os dados de cada centro bem como todos os
* materiais para cada centro sua denominação.
*   Ao final da impressão dos materiais deverá ser impressa no relatório a
* quantidade materiais encontrados para cada um dos centros selecionados.
* Imprimir os campos Centro, Nome 1, País, Região, Nº do material e Denominação.
*----------------------------------------------------------------------------*



TABLES:
  t001w.

TYPES:

  BEGIN OF type_t001w,
    werks TYPE t001w-werks,
    name1 TYPE t001w-name1,
    land1 TYPE t001w-land1,
    regio TYPE t001w-regio,
    fabkl TYPE t001w-fabkl,
  END OF type_t001w,

  BEGIN OF type_marc,
    matnr TYPE marc-matnr,
    werks TYPE marc-werks,
  END OF type_marc,

  BEGIN OF type_makt,
    matnr TYPE makt-matnr,
    spras TYPE makt-spras,
    maktx TYPE makt-maktx,
  END OF type_makt.

DATA:
  ti_t001w TYPE TABLE OF type_t001w,
  ti_marc  TYPE TABLE OF type_marc,
  ti_makt  TYPE TABLE OF type_makt.

DATA:
  wa_t001w TYPE type_t001w,
  wa_marc  TYPE type_marc,
  wa_makt  TYPE type_makt.

DATA:
  v_contador TYPE i,
  v_centro   TYPE t001w-werks.

SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE text-001. "Tela de seleção

SELECT-OPTIONS s_werks FOR  t001w-werks.
PARAMETERS     p_fabkl TYPE t001w-fabkl DEFAULT 'BR'.

SELECTION-SCREEN: END OF BLOCK b1.

FREE ti_t001w.
SELECT werks
       name1
       land1
       regio
       fabkl
  FROM t001w
  INTO TABLE ti_t001w
 WHERE werks IN s_werks
   AND fabkl = p_fabkl.

IF sy-subrc <> 0.

  FREE ti_t001w.
  MESSAGE 'Dados não encontrados!' TYPE 'S' DISPLAY LIKE 'E'.
  LEAVE LIST-PROCESSING.

ENDIF.

IF ti_t001w IS  NOT INITIAL.

  FREE ti_marc.
  SELECT matnr
         werks
    FROM marc
    INTO TABLE ti_marc
     FOR ALL ENTRIES IN ti_t001w
   WHERE werks = ti_t001w-werks.

  IF sy-subrc <> 0.
    FREE ti_marc.
    MESSAGE 'Dados não encontrados!' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDIF.

IF ti_marc IS NOT INITIAL.

  FREE ti_makt.
  SELECT matnr
         spras
         maktx
    FROM makt
    INTO TABLE ti_makt
     FOR ALL ENTRIES IN ti_marc
   WHERE matnr = ti_marc-matnr
     AND matnr = 'PT'.

  IF sy-subrc <> 0.
    FREE ti_makt.
  ENDIF.

ENDIF.

FORMAT COLOR  COL_HEADING INTENSIFIED ON.

WRITE: /01 '|', 'Centro',
       10 '|', 'Nome 1',
       40 '|', 'País',
       50 '|', 'Região',
       60 '|', 'N° material',
       90 '|', 'Denominação',
      120 '|'.

SORT: ti_t001w BY werks,
      ti_marc  BY werks
                  matnr,
      ti_makt  BY matnr.

LOOP AT ti_t001w INTO wa_t001w.

  CLEAR wa_marc.
  READ TABLE ti_marc INTO wa_marc WITH KEY
                                  werks = wa_t001w-werks BINARY SEARCH.

  IF sy-subrc <> 0.
    READ TABLE ti_makt INTO wa_makt WITH KEY
                                    matnr = wa_marc-matnr BINARY SEARCH.
  ENDIF.

  FORMAT RESET.
  FORMAT COLOR COL_POSITIVE.

  WRITE:
   /01 '|', wa_t001w-werks, "Centro
   10  '|', wa_t001w-name1, "Nome 1
   40  '|', wa_t001w-land1, "País
   50  '|', wa_t001w-regio, "Região
   60  '|', wa_marc-matnr,  "Nº material
   90  '|', wa_makt-maktx,  "Denominação
  120  '|'.

  v_contador = v_contador + 1.
  v_centro = wa_t001w-werks.

ENDLOOP.

FORMAT RESET.
FORMAT COLOR COL_TOTAL INTENSIFIED ON.
WRITE:
/01 '|', 'Total de materiais para o centro', v_centro, '=',  v_contador,
120 '|'.
