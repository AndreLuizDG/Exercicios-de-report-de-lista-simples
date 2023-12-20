REPORT z_algj_32
LINE-SIZE 250.

*--------------------------------------------------------------------*
* 8 - Elaborar um programa ABAP onde dever� ser criada uma tela de sele��o com
* o campo Pagador como sele��o m�ltipla, Documento de faturamento como sele��o
* m�ltipla e Organiza��o de vendas como sele��o �nica e valor default �3020�. Seus tipos
* se encontram na tabela VBRK.
*   Selecionar na tabela VBRK todos os Documentos de faturamento que esteja de
* acordo com o campo Pagador da tela de sele��o, Documento de Faturamento da tela de
* sele��o, Organiza��o de vendas da tela de sele��o, Tipo documento de faturamento =
* �F2� e Moeda do documento SD = �USD�. Retornar os campos Documento de
* Faturamento, Data doc.faturamento p/�ndice de docs.faturamto e Pagador.
*   Para cada registro encontrado na tabela VBRK, selecionar os itens de faturamento
* na tabela VBRP onde o campo Documentos de faturamento relaciona as duas tabelas,
* retornando os campos Documento de faturamento, Item do documento de faturamento,
* Quantidade faturada efetivamente, Peso l�quido, Peso bruto, Valor l�quido do item de
* faturamento em moeda do documento e N� do material.
*   Para cada registro encontrado na tabela VBRK, selecionar na tabela KNA1 os
* dados do Pagador onde o campo Pagador da tabela VBRK se relaciona com o campo N�
* cliente 1 da tabela KNA1 e o campo Chave do pa�s = �US�. Retornar os campos N�
* cliente 1, Nome 1, Local, Regi�o (pa�s, estado, prov�ncia, condado) e Rua e n�.
* Para cada registro encontrado na tabela VBRP, selecionar na tabela MAKT a
* descri��o dos materiais onde o campo N� do material relaciona as duas tabelas e o
* campo C�digo de idioma = �PT�. Retornar os campos N� do material e Texto breve de
* material.
*   Para cada Pagador (quebra) encontrado na tabela VBRK o relat�rio deve exibir
* seus Documentos de faturamento e itens do documento de faturamento. No final de cada
* Documento de Faturamento dever� ser apresentada a soma dos campos Quantidade
* faturada efetivamente, Peso l�quido, Peso bruto, Valor l�quido do item de faturamento em
* moeda do documento. No final de cada Pagador tamb�m dever� ser apresentada a
* soma dos campos Quantidade faturada efetivamente, Peso l�quido, Peso bruto, Valor
* l�quido do item de faturamento em moeda do documento. Dever� ser exibido um
* contador com a quantidade de Documento de Faturamento para um mesmo pagador e
*   no final um contador com a quantidade de registros encontrados.
* Imprimir os campos: Pagador, Documento de Faturamento, Data doc.faturamento
* p/�ndice de docs.faturamto, Nome 1, Local, Regi�o, Rua e n�, Item do documento de
* faturamento, N� do material, Texto breve de material, Quantidade faturada efetivamente,
* Peso l�quido, Peso bruto e Valor l�quido do item de faturamento em moeda do
* documento
*--------------------------------------------------------------------*

TYPES:

  BEGIN OF type_vbrk,
    vbeln TYPE vbrk-vbeln,  "Documento de faturamento
    fkart TYPE vbrk-fkart,  "Tipo documento de faturamento
    waerk TYPE vbrk-waerk,  "Moeda do documento SD
    fkdat TYPE vbrk-fkdat,  "Data doc.faturamento p/�ndice de docs.faturamto.e impress�o
    kunrg TYPE vbrk-kunrg,  "Pagador
  END OF type_vbrk,

  BEGIN OF type_vbrp,
    vbeln TYPE vbrp-vbeln,  "Documento de faturamento
    posnr TYPE vbrp-posnr,  "Item do documento de faturamento
    fkimg TYPE vbrp-fkimg,  "Quantidade faturada efetivamente
    ntgew TYPE vbrp-ntgew,  "Peso l�quido
    brgew TYPE vbrp-brgew,  "Peso bruto
    netwr TYPE vbrp-netwr,  "Valor l�quido do item de faturamento em moeda do documento
    matnr TYPE vbrp-matnr,  "N� do material
  END OF type_vbrp,

  BEGIN OF type_kna1,
    kunnr TYPE kna1-kunnr,  "N� cliente
    land1 TYPE kna1-land1,  "Chave do pa�s
    name1 TYPE kna1-name1,  "Nome 1
    ort01 TYPE kna1-ort01,  "Local
    regio TYPE kna1-regio,  "Regi�o (estado federal, estado federado, prov�ncia, condado)
    stras TYPE kna1-stras,  "Rua e n�
  END OF type_kna1,

  BEGIN OF type_makt,
    matnr TYPE makt-matnr,  "N� do material
    spras TYPE makt-spras,  "C�digo de idioma
    maktx TYPE makt-maktx,  "Texto breve de material
  END OF type_makt.

DATA: ti_vbrk     TYPE TABLE OF type_vbrk,
      ti_makt     TYPE TABLE OF type_makt,
      ti_vbrp     TYPE TABLE OF type_vbrp,
      ti_kna1     TYPE TABLE OF type_kna1,
      ti_kna1_aux TYPE TABLE OF type_kna1.

DATA: wa_vbrk TYPE type_vbrk,
      wa_makt TYPE type_makt,
      wa_vbrp TYPE type_vbrp,
      wa_kna1 TYPE type_kna1.

DATA:
      v_pagador TYPE type_vbrk-kunrg.

FREE ti_vbrk.
SELECT vbeln  "Documento de faturamento
       fkart  "Tipo documento de faturamento
       waerk  "Moeda do documento SD
       fkdat  "Data doc.faturamento p/�ndice de docs.faturamto.e impress�o
       kunrg  "Pagador
  FROM vbrk
  INTO TABLE ti_vbrk
 WHERE fkart = 'F2'
   AND waerk = 'USD'.

IF sy-subrc = 0.

  LOOP AT ti_vbrk INTO wa_vbrk.

    wa_kna1-kunnr = wa_vbrk-kunrg.
    APPEND wa_kna1 TO ti_kna1_aux.

  ENDLOOP.

ENDIF.

CLEAR wa_kna1.

IF ti_vbrk IS NOT INITIAL.

  FREE ti_vbrp.
  SELECT vbeln  "Documento de faturamento
         posnr  "Item do documento de faturamento
         fkimg  "Quantidade faturada efetivamente
         ntgew  "Peso l�quido
         brgew  "Peso bruto
         netwr  "Valor l�quido do item de faturamento em moeda do documento
         matnr  "N� do material
    FROM vbrp
    INTO TABLE ti_vbrp
     FOR ALL ENTRIES IN ti_vbrk
   WHERE vbeln = ti_vbrk-vbeln.

ENDIF.

IF ti_kna1_aux IS NOT INITIAL.

  FREE ti_kna1.
  SELECT kunnr  "N� cliente
         land1  "Chave do pa�s
         name1  "Nome 1
         ort01  "Local
         regio  "Regi�o (estado federal, estado federado, prov�ncia, condado)
         stras  "Rua e n�
    FROM kna1
    INTO TABLE ti_kna1
     FOR ALL ENTRIES IN ti_kna1_aux
   WHERE kunnr = ti_kna1_aux-kunnr
     AND land1 = 'US'.

ENDIF.

IF ti_vbrp IS NOT INITIAL.

  FREE ti_makt.
  SELECT matnr  "N� do material
         spras  "C�digo de idioma
         maktx  "Texto breve de material
    FROM makt
    INTO TABLE ti_makt
     FOR ALL ENTRIES IN ti_vbrp
   WHERE matnr = ti_vbrp-matnr
     AND spras = 'PT'.

ENDIF.

SORT: ti_vbrk BY vbeln
                 kunrg,
      ti_vbrp BY vbeln
                 matnr,
      ti_kna1 BY kunnr,
      ti_makt BY matnr.


LOOP AT ti_vbrk INTO wa_vbrk.

  CLEAR wa_vbrp.
  READ TABLE ti_vbrp INTO wa_vbrp WITH KEY
                                  vbeln = wa_vbrk-vbeln BINARY SEARCH.

  CLEAR wa_kna1.
  READ TABLE ti_kna1 INTO wa_kna1 WITH KEY
                                  kunnr = wa_vbrk-kunrg BINARY SEARCH.

  CLEAR wa_makt.
  READ TABLE ti_makt INTO wa_makt WITH KEY
                                  matnr = wa_vbrp-matnr BINARY SEARCH.

  IF v_pagador <> wa_vbrk-kunrg.

    FORMAT RESET.
    FORMAT COLOR COL_KEY INTENSIFIED OFF.
    WRITE:
    /,
    /01 '|', 'Pagador',
     20 '|', 'Documento de Faturamento',
     50 '|', 'Data doc.faturamento p/�ndice de docs.faturamto',
    220 '|'.

    FORMAT RESET.
    FORMAT COLOR COL_HEADING INTENSIFIED OFF.
    WRITE:
    /01 '|', wa_vbrk-kunrg, " Pagador
     20 '|', wa_vbrk-vbeln, " Documento de Faturamento
     50 '|', wa_vbrk-fkdat, " Data doc.faturamento p/�ndice de docs.faturamto
    220 '|'.

    FORMAT RESET.
    FORMAT COLOR COL_KEY INTENSIFIED OFF.
    WRITE:
    /01 '|', 'Nome 1',
     40 '|', 'Local',
     80 '|', 'Regi�o',
     90 '|', 'Rua e n�',
    220 '|'.

    FORMAT RESET.
    FORMAT COLOR COL_HEADING INTENSIFIED OFF.
    WRITE:
    /01 '|', wa_kna1-name1, " Nome 1
     40 '|', wa_kna1-ort01, " Local
     80 '|', wa_kna1-regio, " Regi�o
     90 '|', wa_kna1-stras, " Rua e n�
    220 '|'.

    v_pagador = wa_vbrk-kunrg.

    FORMAT RESET.
    FORMAT COLOR COL_KEY INTENSIFIED OFF.
    WRITE:
    /01 '|', 'Item do documento de faturamento',
     40 '|', 'N� do material',
     60 '|', 'Texto breve de material',
    100 '|', 'Quantidade faturada efetivamente',
    120 '|', 'Peso l�quido',
    140 '|', 'Peso bruto',
    160 '|', 'Valor l�q. item fatu. moeda doc.',
    220 '|'.

  ENDIF. "IF v_pagador <> wa_vbrk-kunrg.

  FORMAT RESET.
  FORMAT COLOR COL_HEADING INTENSIFIED OFF.
  WRITE:
  /01 '|', wa_vbrp-posnr, " Item do documento de faturamento
   40 '|', wa_vbrp-matnr, " N� do material
   60 '|', wa_makt-maktx, " Texto breve de material
  100 '|', wa_vbrp-fkimg, " Quantidade faturada efetivamente
  120 '|', wa_vbrp-ntgew, " Peso l�quido
  140 '|', wa_vbrp-brgew, " Peso bruto
  160 '|', wa_vbrp-netwr, " Valor l�quido do item de faturamento em moeda do documento
  220 '|'.

ENDLOOP.
