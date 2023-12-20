REPORT z_algj_30.

*--------------------------------------------------------------------*
* 6 - Elaborar um programa ABAP onde deverá ser criada uma tela de seleção com
* o Centro de lucro como seleção múltipla e a Área de contabilidade de custos também
* como seleção múltipla. Seus tipos se encontram na tabela CEPC.
*   Selecionar na tabela CEPC todos os Centros de lucro e Área de contabilidade de
* custos que estiverem de acordo com os dois campos da tela de seleção e a Data de
* validade final for igual a 31.12.9999, retornando os campos Centro de lucro, Data de
* validade final, Área de contabilidade de custos, Data início validade e Criado por.
*   Para cada registro encontrado na tabela CEPC, selecionar na tabela CEPCT as
* descrições dos Centros de lucro, onde Código de idioma = ‘PT’ e as duas tabelas são
* relacionadas pelos campos Centro de lucro, Data de validade final e Área de
* contabilidade de custos, retornando os campos Centro de lucro, Data de validade final,
*   Área de contabilidade de custos e Texto descritivo.
*   Para cada registro encontrado na tabela CEPC, selecionar na tabela TKA01 as
* descrições das Áreas de contabilidade de custos encontradas onde, o campo Área de
* contabilidade de custos relaciona as duas tabelas. Retornar os campos Área de
* contabilidade de custos e Denominação da área de contabilidade de custos
*   O relatório deve imprimir todos os Centros de Lucro de cada Área de contabilidade
* de custos selecionada. Para cada Área de contabilidade de custos deverá mostrar um
* contador de Centros de Lucro e no final do relatório a quantidade de registros
* encontrados.
*   Imprimir os campos: Área de contabilidade de custos, Denominação da área de
* contabilidade de custos, Centro de lucro, Texto descritivo, Criado por, Data início
* validade, Data de validade final.
*--------------------------------------------------------------------*

TYPES:

  BEGIN OF type_cepc,
    prctr TYPE cepc-prctr,  "Centro de lucro
    datbi TYPE cepc-datbi,  "Data de validade final
    kokrs TYPE cepc-kokrs,  "Área de contabilidade de custos
    datab TYPE cepc-datab,  "Data início validade
    usnam TYPE cepc-usnam,  "Criado por
  END OF type_cepc,

  BEGIN OF type_cepct,
    spras TYPE cepct-spras,  "Código de idioma
    prctr TYPE cepct-prctr,  "Centro de lucro
    datbi TYPE cepct-datbi,  "Data de validade final
    kokrs TYPE cepct-kokrs,  "Área de contabilidade de custos
  END OF type_cepct,

  BEGIN OF type_tka01,
    kokrs TYPE tka01-kokrs,  "Área de contabilidade de custos
    bezei TYPE tka01-bezei,  "Denominação da área de contabilidade de custos
  END OF type_tka01.

DATA:
  ti_cepc  TYPE TABLE OF type_cepc,
  ti_cepct TYPE TABLE OF type_cepct,
  ti_tka01 TYPE TABLE OF type_tka01.

DATA:
  wa_cepc  TYPE type_cepc,
  wa_cepct TYPE type_cepct,
  wa_tka01 TYPE type_tka01.

DATA:
  v_area      TYPE type_cepc-kokrs,
  v_cont_area TYPE i,
  v_cont_regi TYPE i.

FREE ti_cepc.
SELECT prctr  "Centro de lucro
       datbi  "Data de validade final
       kokrs  "Área de contabilidade de custos
       datab  "Data início validade
       usnam  "Criado por
  FROM cepc
  INTO TABLE ti_cepc
 WHERE datbi = '99991231'.

IF sy-subrc <> 0.
  FREE ti_cepc.
ENDIF.

IF ti_cepc IS NOT INITIAL.

  FREE ti_cepct.
  SELECT spras  "Código de idioma
         prctr  "Centro de lucro
         datbi  "Data de validade final
         kokrs  "Área de contabilidade de custos
    FROM cepct
    INTO TABLE ti_cepct
     FOR ALL ENTRIES IN ti_cepc
   WHERE spras = 'PT'
     AND prctr = ti_cepc-prctr
     AND datbi = ti_cepc-datbi
     AND kokrs = ti_cepc-kokrs.

  IF sy-subrc <> 0.
    FREE ti_cepct.
  ENDIF.

ENDIF. "IF TI_CEPC IS NOT INITIAL.

FREE ti_tka01.
SELECT kokrs  "Área de contabilidade de custos
       bezei  "Denominação da área de contabilidade de custos
  FROM tka01
  INTO TABLE ti_tka01
   FOR ALL ENTRIES IN ti_cepc
 WHERE kokrs = ti_cepc-kokrs.

IF sy-subrc <> 0.
  FREE ti_tka01.
ENDIF.

SORT: ti_cepc  BY prctr
                  datbi
                  kokrs,
      ti_cepct BY prctr
                  datbi
                  kokrs,
      ti_tka01 BY kokrs.

LOOP AT ti_cepc INTO wa_cepc.

  CLEAR wa_cepct.
  READ TABLE ti_cepct INTO wa_cepct WITH KEY
                                    prctr = wa_cepc-prctr
                                    datbi = wa_cepc-datbi
                                    kokrs = wa_cepc-kokrs BINARY SEARCH.

  IF sy-subrc <> 0.
    CLEAR wa_cepct.
  ENDIF.

  CLEAR wa_tka01.
  READ TABLE ti_tka01 INTO wa_tka01 WITH KEY
                                    kokrs = wa_cepc-kokrs BINARY SEARCH.

  IF sy-subrc <> 0.
    CLEAR wa_tka01.
  ENDIF.


  IF v_area <> wa_cepc-kokrs.

    IF v_area IS NOT INITIAL.

      FORMAT RESET.
      FORMAT COLOR COL_TOTAL INTENSIFIED OFF.
      WRITE:
      /01 'Total de Centros de Lucro para a Área', v_area, ' = ', v_cont_area,
      140 '|'.

    ENDIF.

    CLEAR v_cont_area.

    CLEAR v_area.
    FORMAT RESET.
    FORMAT COLOR COL_KEY INTENSIFIED ON.

    WRITE:
    /01 '|', 'Área de contabilidade de custos',
     40 '|', 'Denominação da área de contabilidade de custos',
    140 '|'.

    FORMAT RESET.
    FORMAT COLOR COL_HEADING INTENSIFIED OFF.
    WRITE:
    /01 '|', wa_cepc-kokrs,  "Área de contabilidade de custos
     40 '|', wa_tka01-bezei, "Denominação da área de contabilidade de custos
    140 '|'.

    FORMAT RESET.
    FORMAT COLOR COL_KEY INTENSIFIED ON.

    WRITE:
    /01 '|', 'Centro de lucro',
     40 '|', 'Texto descritivo',
     60 '|', 'Criado por',
     90 '|', 'Data início validade',
    110 '|', 'Data de validade final',
    140 '|'.

    v_area = wa_cepc-kokrs.

  ENDIF. "IF v_area <> kokrs.

  FORMAT RESET.
  FORMAT COLOR COL_HEADING INTENSIFIED OFF.
  WRITE:
  /01 '|', wa_cepc-prctr,  "Centro de lucro
   40 '|', wa_tka01-bezei, "Texto descritivo
   60 '|', wa_cepc-usnam,  "Criado por
   90 '|', wa_cepc-datab,  "Data início validade
  110 '|', wa_cepct-datbi, "Data de validade final
  140 '|'.
  v_cont_area = v_cont_area + 1.

  v_cont_regi = v_cont_regi + 1.

ENDLOOP.

FORMAT RESET.
FORMAT COLOR COL_TOTAL INTENSIFIED OFF.
WRITE:
/01 '|', 'Total de registros selecionados =', v_cont_regi, 140 '|'.
