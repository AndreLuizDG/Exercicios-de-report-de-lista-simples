REPORT z_algj_27.

*--------------------------------------------------------------------*
* 3 - Elaborar um programa ABAP onde deverão ser selecionados na tabela VBAK
* as ordens de venda criadas no mês 02/2008, retornando os campos Documento de
* vendas, Data de criação do registro, Tipo de documento de vendas e Emissor da ordem.
*   Para cada ordem de venda encontrada na tabela VBAK selecionar na tabela
* VBAP seus itens onde o campo Documento de vendas relaciona as duas tabelas,
* retornando os campos Documento de vendas, Item do documento de vendas, Nº do
* material, Quantidade da ordem acumulada em unidade de venda e Valor líquido do item
* da ordem na moeda do documento. Imprimir todos os itens de cada ordem de venda.
*   Na impressão do resultado, efetuar uma quebra no relatório pelo campo Emissor
* da Ordem, onde deverá ser impresso a quantidade de ordens encontrada para cada um
* dos emissores selecionados.
*   Imprimir os campos: Emissor da ordem, Tipo de documento de vendas, Data de
* criação do registro, Documento de vendas, Item do documento de vendas, Nº do
* material, Quantidade da ordem acumulada em unidade de venda e Valor líquido do item
* da ordem na moeda do documento.
*--------------------------------------------------------------------*


TYPES:

  BEGIN OF type_vbak,
    vbeln TYPE vbak-vbeln,
    erdat TYPE vbak-erdat,
    auart TYPE vbak-auart,
    kunnr TYPE vbak-kunnr,
  END OF type_vbak,

  BEGIN OF type_vbap,
    vbeln  TYPE vbap-vbeln,
    posnr  TYPE vbap-posnr,
    matnr  TYPE vbap-matnr,
    kwmeng TYPE vbap-kwmeng,
    netwr  TYPE vbap-netwr,
  END OF type_vbap.

DATA:
  ti_vbak TYPE TABLE OF type_vbak,
  ti_vbap TYPE TABLE OF type_vbap.

DATA:
  wa_vbak TYPE type_vbak,
  wa_vbap TYPE type_vbap.

DATA:
  v_emissor  TYPE vbak-kunnr,
  v_contador TYPE i.

SELECT vbeln
       erdat
       auart
       kunnr
  FROM vbak
  INTO TABLE ti_vbak.

IF sy-subrc = 0.

  LOOP AT ti_vbak INTO wa_vbak.
    IF wa_vbak-erdat+4(2) <> '08'.
      DELETE ti_vbak INDEX sy-tabix.
    ENDIF. "IF wa_vbak-erdat+4(2) <> '08'.
  ENDLOOP.

ELSE.

  FREE ti_vbak.
  MESSAGE 'Dados não encontrados!' TYPE 'S' DISPLAY LIKE 'E'.
  LEAVE LIST-PROCESSING.

ENDIF. "IF sy-subrc = 0.

IF ti_vbak IS NOT INITIAL.

  SELECT vbeln
         posnr
         matnr
         kwmeng
         netwr
    FROM vbap
    INTO TABLE ti_vbap
     FOR ALL ENTRIES IN ti_vbak
   WHERE vbeln = ti_vbak-vbeln.

  IF sy-subrc <> 0.

    FREE ti_vbap.
    MESSAGE 'Dados não encontrados!' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.

  ENDIF. "IF sy-subrc <> 0.

ENDIF. "IF ti_vbak IS NOT INITIAL.

SORT: ti_vbak BY vbeln,
      ti_vbap BY vbeln.


LOOP AT ti_vbak INTO wa_vbak.

  READ TABLE ti_vbap INTO wa_vbap WITH KEY
                                  vbeln = wa_vbak-vbeln BINARY SEARCH.

* Na impressão do resultado, efetuar uma quebra no relatório pelo campo Emissor
* da Ordem, onde deverá ser impresso a quantidade de ordens encontrada para cada um
* dos emissores selecionados.

  IF sy-tabix <> 1.
    v_contador = v_contador + 1.
  ENDIF.

  IF v_emissor NE wa_vbak-kunnr.


    FORMAT RESET.

    IF sy-tabix <> 1.
      ULINE.
      WRITE:/ 'Emissor: ', v_emissor.
      WRITE:/ 'Total de Registros: ', v_contador.

      CLEAR v_contador.
    ENDIF.

    v_emissor = wa_vbak-kunnr.

    FORMAT COLOR COL_HEADING INTENSIFIED ON.
    ULINE.
    WRITE: /01 '|', 'Emissor',
            15 '|', 'Tipo de doc.',
            30 '|', 'Data de criaçãodo',
            60 '|', 'Doc. de vendas',
            80 '|', 'Item do doc. vendas',
           100 '|', 'Nº do material',
           120 '|', 'Quantidade da ordem',
           140 '|', 'Valor líquido do item',
           180 '|'.
    ULINE.

  ENDIF. " IF v_emissor NE wa_vbak-kunnr.

  FORMAT RESET.
  WRITE:
        /01 '|', wa_vbak-kunnr," Emissor da ordem
         15 '|', wa_vbak-auart," Tipo de documento de vendas
         30 '|', wa_vbak-erdat," Data de criação do registro
         60 '|', wa_vbak-vbeln," Documento de vendas
         80 '|', wa_vbap-posnr," Item do documento de vendas
        100 '|', wa_vbap-matnr," Nº do material
        120 '|', wa_vbap-kwmeng," Quantidade da ordem acumulada em unidade de venda
        140 '|', wa_vbap-netwr," Valor líquido do item da ordem na moeda do documento
        180 '|'.


ENDLOOP.
