# encoding: utf-8
require 'spec_helper'

describe "NLP" do

  let(:input_file) { '/Users/stranbird/Documents/NLP/TrainingData.txt' }
  let(:normalized_text) { '用先进典型推动部队全面建设据{新华社}{北京}１２月３１日电（记者{罗玉文}）{中央军委}委员、总政治部主任{于永波}日前在会见全军和武警部队先进典型代表时强调，全军要认真贯彻落实{江泽民}主席最近的重要指示精神，形成学习邓小平理论的新高潮，把这一学习提高到十五大所达到的新水平，进一步加强军队的革命化、现代化、正规化建设。{于永波}等在同应邀参加中宣部召开的全国先进典型座谈会的军队代表{徐洪刚}、{韩素云}、{李国安}、{邹延龄}、{第四军医大学}学员二大队代表{李尔青}以及{武警部队国旗护卫队}代表{王建华}座谈时，称赞他们的先进事迹是中华民族传统美德和我党我军优良传统的完美结合，体现了我党我军全心全意为人民服务的宗旨，体现了与社会主义市场经济相适应的时代精神。{于永波}指出，我军是一支英雄模范辈出的军队，用先进典型教育部队是我军政治工作的优良传统。他说，要充分发挥先进典型的示范、激励、感召作用，在部队营造学习先进、奋发向上的良好风气。要把向英雄模范学习同做好部队的各项工作紧密结合起来，爱岗敬业，在各自的岗位上为军队和国防建设贡献聪明才智，按照{江主席}“五句话”的总要求，推动部队全面建设。总政副主任{周子玉}、{唐天标}、{袁守芳}等参加了会见。' }
  let(:normalized_text_without_bracket) { '用先进典型推动部队全面建设据新华社北京１２月３１日电（记者罗玉文）中央军委委员、总政治部主任于永波日前在会见全军和武警部队先进典型代表时强调，全军要认真贯彻落实江泽民主席最近的重要指示精神，形成学习邓小平理论的新高潮，把这一学习提高到十五大所达到的新水平，进一步加强军队的革命化、现代化、正规化建设。于永波等在同应邀参加中宣部召开的全国先进典型座谈会的军队代表徐洪刚、韩素云、李国安、邹延龄、第四军医大学学员二大队代表李尔青以及武警部队国旗护卫队代表王建华座谈时，称赞他们的先进事迹是中华民族传统美德和我党我军优良传统的完美结合，体现了我党我军全心全意为人民服务的宗旨，体现了与社会主义市场经济相适应的时代精神。于永波指出，我军是一支英雄模范辈出的军队，用先进典型教育部队是我军政治工作的优良传统。他说，要充分发挥先进典型的示范、激励、感召作用，在部队营造学习先进、奋发向上的良好风气。要把向英雄模范学习同做好部队的各项工作紧密结合起来，爱岗敬业，在各自的岗位上为军队和国防建设贡献聪明才智，按照江主席“五句话”的总要求，推动部队全面建设。总政副主任周子玉、唐天标、袁守芳等参加了会见。' }
  let(:segmented_text) { '用 先进 典型 推动 部队 全面 建设 据 新华社 北京 １２月 ３１日 电 （ 记者 罗玉文 ） 中央军委 委员 、 总 政治部 主任 于永波 日前 在 会见 全军 和 武警 部队 先进 典型 代表 时 强调 ， 全 军 要 认真 贯彻 落实 江泽民 主席 最近 的 重要 指示 精神 ， 形成 学习 邓小平 理论 的 新 高潮 ， 把 这 一 学习 提高 到 十五 大 所 达到 的 新 水平 ， 进一步 加强 军队 的 革命化 、 现代化 、 正规化 建设 。 于永波 等 在 同 应邀 参加 中宣部 召开 的 全国 先进 典型 座谈会 的 军队 代表 徐洪刚 、 韩素云 、 李国安 、 邹延龄 、 第四军医大学 学员 二大队 代表 李尔青 以及 武警部队国旗护卫队 代表 王建华 座谈 时 ， 称赞 他们 的 先进 事迹 是 中华 民族 传统 美德 和 我 党 我 军 优良 传统 的 完美 结合 ， 体现 了 我 党 我军 全心全意 为 人民 服务 的 宗旨 ， 体现 了 与 社会主义 市场 经济 相 适应 的 时代 精神 。 于永波 指出 ， 我军 是 一 支 英雄 模范 辈出 的 军队 ， 用 先进 典型 教育 部队 是 我军 政治 工作 的 优良 传统 。 他 说 ， 要 充分 发挥 先进 典型 的 示范 、 激励 、 感召 作用 ， 在 部队 营造 学习 先进 、 奋发 向上 的 良好 风气 。 要 把 向 英雄 模范 学习 同 做好 部队 的 各 项 工作 紧密 结合 起来 ， 爱岗 敬业 ， 在 各自 的 岗位 上 为 军队 和 国防 建设 贡献 聪明才智 ， 按照 江主席 “ 五 句 话 ” 的 总 要求 ， 推动 部队 全面 建设 。 总政 副主任 周子玉 、 唐天标 、 袁守芳 等 参加 了 会见 。' }
  let(:segmented_text_without_bracket) { '用 先进 典型 推动 部队 全面 建设 据 新华社 北京 １２月 ３１日 电 （ 记者 罗玉文 ） 中央 军委 委员 、 总 政治部 主任 于永波 日前 在 会见 全军 和 武警 部队 先进 典型 代表 时 强调 ， 全 军 要 认真 贯彻 落实 江泽民 主席 最近 的 重要 指示 精神 ， 形成 学习 邓小平 理论 的 新 高潮 ， 把 这 一 学习 提高 到 十五 大 所 达到 的 新 水平 ， 进一步 加强 军队 的 革命化 、 现代化 、 正规化 建设 。 于永波 等 在 同 应邀 参加 中宣部 召开 的 全国 先进 典型 座谈会 的 军队 代表 徐洪刚 、 韩素云 、 李国安 、 邹延龄 、 第四 军医 大学 学员 二大队 代表 李尔青 以及 武警 部队 国旗 护卫队 代表 王建华 座谈 时 ， 称赞 他们 的 先进 事迹 是 中华 民族 传统 美德 和 我 党 我 军 优良 传统 的 完美 结合 ， 体现 了 我 党 我军 全心全意 为 人民 服务 的 宗旨 ， 体现 了 与 社会主义 市场 经济 相 适应 的 时代 精神 。 于永波 指出 ， 我军 是 一 支 英雄 模范 辈出 的 军队 ， 用 先进 典型 教育 部队 是 我军 政治 工作 的 优良 传统 。 他 说 ， 要 充分 发挥 先进 典型 的 示范 、 激励 、 感召 作用 ， 在 部队 营造 学习 先进 、 奋发 向上 的 良好 风气 。 要 把 向 英雄 模范 学习 同 做好 部队 的 各 项 工作 紧密 结合 起来 ， 爱岗 敬业 ， 在 各自 的 岗位 上 为 军队 和 国防 建设 贡献 聪明才智 ， 按照 江 主席 “ 五 句 话 ” 的 总 要求 ， 推动 部队 全面 建设 。 总政 副主任 周子玉 、 唐天标 、 袁守芳 等 参加 了 会见 。' }
  let(:postagged_text) { '用#P 先进#JJ 典型#NN 推动#VV 部队#NN 全面#AD 建设#VV 据#P 新华社#NR 北京#NR １２月#NT ３１日#NT 电#NN （#PU 记者#NN 罗玉文#NR ）#PU 中央军委#NN 委员#NN 、#PU 总#JJ 政治部#NN 主任#NN 于永波#NR 日前#NT 在#P 会见#VV 全军#NN 和#CC 武警#NN 部队#NN 先进#JJ 典型#NN 代表#NN 时#LC 强调#VV ，#PU 全#DT 军#NN 要#VV 认真#AD 贯彻#VV 落实#VV 江泽民#NR 主席#NN 最近#NT 的#DEG 重要#JJ 指示#NN 精神#NN ，#PU 形成#VV 学习#VV 邓小平#NR 理论#NN 的#DEG 新#JJ 高潮#NN ，#PU 把#BA 这#DT 一#CD 学习#NN 提高#VV 到#VV 十五#CD 大#JJ 所#MSP 达到#VV 的#DEC 新#JJ 水平#NN ，#PU 进一步#AD 加强#VV 军队#NN 的#DEG 革命化#NN 、#PU 现代化#NN 、#PU 正规化#JJ 建设#NN 。#PU 于永波#NR 等#ETC 在#P 同#P 应邀#VV 参加#VV 中宣部#NR 召开#VV 的#DEC 全国#JJ 先进#JJ 典型#NN 座谈会#NN 的#DEG 军队#NN 代表#NN 徐洪刚#NR 、#PU 韩素云#NR 、#PU 李国安#NR 、#PU 邹延龄#NR 、#PU 第四军医大学#NR 学员#NN 二大队#NN 代表#NN 李尔青#NR 以及#CC 武警部队国旗护卫队#NR 代表#NN 王建华#NR 座谈#VV 时#LC ，#PU 称赞#VV 他们#PN 的#DEG 先进#JJ 事迹#NN 是#VC 中华#NR 民族#NN 传统#JJ 美德#NN 和#CC 我#PN 党#NN 我#PN 军#NN 优良#VA 传统#VA 的#DEC 完美#NN 结合#VV ，#PU 体现#VV 了#AS 我#PN 党#NN 我军#NN 全心全意#AD 为#P 人民#NN 服务#VV 的#DEC 宗旨#NN ，#PU 体现#VV 了#AS 与#P 社会主义#NN 市场#NN 经济#NN 相#AD 适应#VV 的#DEC 时代#NN 精神#NN 。#PU 于永波#NR 指出#VV ，#PU 我军#NN 是#VC 一#CD 支#M 英雄#NN 模范#NN 辈出#VV 的#DEC 军队#NN ，#PU 用#P 先进#JJ 典型#JJ 教育#NN 部队#NN 是#VC 我军#NN 政治#NN 工作#NN 的#DEG 优良#JJ 传统#NN 。#PU 他#PN 说#VV ，#PU 要#VV 充分#AD 发挥#VV 先进#JJ 典型#JJ 的#DEG 示范#NN 、#PU 激励#VV 、#PU 感召#NN 作用#NN ，#PU 在#P 部队#NN 营造#VV 学习#VV 先进#VA 、#PU 奋发#VV 向上#VV 的#DEC 良好#JJ 风气#NN 。#PU 要#VV 把#BA 向#P 英雄#NN 模范#NN 学习#VV 同#P 做好#VV 部队#NN 的#DEG 各#DT 项#M 工作#NN 紧密#AD 结合#VV 起来#VV ，#PU 爱岗#VV 敬业#VV ，#PU 在#P 各自#PN 的#DEG 岗位#NN 上#LC 为#P 军队#NN 和#CC 国防#NN 建设#NN 贡献#NN 聪明才智#NN ，#PU 按照#P 江主席#NN “#PU 五#CD 句#M 话#NN ”#PU 的#DEG 总#JJ 要求#NN ，#PU 推动#VV 部队#NN 全面#AD 建设#VV 。#PU 总政#NN 副主任#NN 周子玉#NR 、#PU 唐天标#NR 、#PU 袁守芳#NR 等#ETC 参加#VV 了#AS 会见#NN 。#PU' }
  let(:linerized_text) { "用#P\n先进#JJ\n典型#NN\n推动#VV\n部队#NN\n全面#AD\n建设#VV\n据#P\n新华社#NR\n北京#NR\n１２月#NT\n３１日#NT\n电#NN\n（#PU\n记者#NN\n罗玉文#NR\n）#PU\n中央军委#NN\n委员#NN\n、#PU\n总#JJ\n政治部#NN\n主任#NN\n于永波#NR\n日前#NT\n在#P\n会见#VV\n全军#NN\n和#CC\n武警#NN\n部队#NN\n先进#JJ\n典型#NN\n代表#NN\n时#LC\n强调#VV\n，#PU\n全#DT\n军#NN\n要#VV\n认真#AD\n贯彻#VV\n落实#VV\n江泽民#NR\n主席#NN\n最近#NT\n的#DEG\n重要#JJ\n指示#NN\n精神#NN\n，#PU\n形成#VV\n学习#VV\n邓小平#NR\n理论#NN\n的#DEG\n新#JJ\n高潮#NN\n，#PU\n把#BA\n这#DT\n一#CD\n学习#NN\n提高#VV\n到#VV\n十五#CD\n大#JJ\n所#MSP\n达到#VV\n的#DEC\n新#JJ\n水平#NN\n，#PU\n进一步#AD\n加强#VV\n军队#NN\n的#DEG\n革命化#NN\n、#PU\n现代化#NN\n、#PU\n正规化#JJ\n建设#NN\n。#PU\n于永波#NR\n等#ETC\n在#P\n同#P\n应邀#VV\n参加#VV\n中宣部#NR\n召开#VV\n的#DEC\n全国#JJ\n先进#JJ\n典型#NN\n座谈会#NN\n的#DEG\n军队#NN\n代表#NN\n徐洪刚#NR\n、#PU\n韩素云#NR\n、#PU\n李国安#NR\n、#PU\n邹延龄#NR\n、#PU\n第四军医大学#NR\n学员#NN\n二大队#NN\n代表#NN\n李尔青#NR\n以及#CC\n武警部队国旗护卫队#NR\n代表#NN\n王建华#NR\n座谈#VV\n时#LC\n，#PU\n称赞#VV\n他们#PN\n的#DEG\n先进#JJ\n事迹#NN\n是#VC\n中华#NR\n民族#NN\n传统#JJ\n美德#NN\n和#CC\n我#PN\n党#NN\n我#PN\n军#NN\n优良#VA\n传统#VA\n的#DEC\n完美#NN\n结合#VV\n，#PU\n体现#VV\n了#AS\n我#PN\n党#NN\n我军#NN\n全心全意#AD\n为#P\n人民#NN\n服务#VV\n的#DEC\n宗旨#NN\n，#PU\n体现#VV\n了#AS\n与#P\n社会主义#NN\n市场#NN\n经济#NN\n相#AD\n适应#VV\n的#DEC\n时代#NN\n精神#NN\n。#PU\n于永波#NR\n指出#VV\n，#PU\n我军#NN\n是#VC\n一#CD\n支#M\n英雄#NN\n模范#NN\n辈出#VV\n的#DEC\n军队#NN\n，#PU\n用#P\n先进#JJ\n典型#JJ\n教育#NN\n部队#NN\n是#VC\n我军#NN\n政治#NN\n工作#NN\n的#DEG\n优良#JJ\n传统#NN\n。#PU\n他#PN\n说#VV\n，#PU\n要#VV\n充分#AD\n发挥#VV\n先进#JJ\n典型#JJ\n的#DEG\n示范#NN\n、#PU\n激励#VV\n、#PU\n感召#NN\n作用#NN\n，#PU\n在#P\n部队#NN\n营造#VV\n学习#VV\n先进#VA\n、#PU\n奋发#VV\n向上#VV\n的#DEC\n良好#JJ\n风气#NN\n。#PU\n要#VV\n把#BA\n向#P\n英雄#NN\n模范#NN\n学习#VV\n同#P\n做好#VV\n部队#NN\n的#DEG\n各#DT\n项#M\n工作#NN\n紧密#AD\n结合#VV\n起来#VV\n，#PU\n爱岗#VV\n敬业#VV\n，#PU\n在#P\n各自#PN\n的#DEG\n岗位#NN\n上#LC\n为#P\n军队#NN\n和#CC\n国防#NN\n建设#NN\n贡献#NN\n聪明才智#NN\n，#PU\n按照#P\n江主席#NN\n“#PU\n五#CD\n句#M\n话#NN\n”#PU\n的#DEG\n总#JJ\n要求#NN\n，#PU\n推动#VV\n部队#NN\n全面#AD\n建设#VV\n。#PU\n总政#NN\n副主任#NN\n周子玉#NR\n、#PU\n唐天标#NR\n、#PU\n袁守芳#NR\n等#ETC\n参加#VV\n了#AS\n会见#NN\n。#PU" }
  let(:crf_input) { "用 P\n先进 JJ\n典型 NN\n推动 VV\n部队 NN\n全面 AD\n建设 VV\n据 P\n新华社 NR\n北京 NR\n１２月 NT\n３１日 NT\n电 NN\n（ PU\n记者 NN\n罗玉文 NR\n） PU\n中央军委 NN\n委员 NN\n、 PU\n总 JJ\n政治部 NN\n主任 NN\n于永波 NR\n日前 NT\n在 P\n会见 VV\n全军 NN\n和 CC\n武警 NN\n部队 NN\n先进 JJ\n典型 NN\n代表 NN\n时 LC\n强调 VV\n， PU\n全 DT\n军 NN\n要 VV\n认真 AD\n贯彻 VV\n落实 VV\n江泽民 NR\n主席 NN\n最近 NT\n的 DEG\n重要 JJ\n指示 NN\n精神 NN\n， PU\n形成 VV\n学习 VV\n邓小平 NR\n理论 NN\n的 DEG\n新 JJ\n高潮 NN\n， PU\n把 BA\n这 DT\n一 CD\n学习 NN\n提高 VV\n到 VV\n十五 CD\n大 JJ\n所 MSP\n达到 VV\n的 DEC\n新 JJ\n水平 NN\n， PU\n进一步 AD\n加强 VV\n军队 NN\n的 DEG\n革命化 NN\n、 PU\n现代化 NN\n、 PU\n正规化 JJ\n建设 NN\n。 PU\n于永波 NR\n等 ETC\n在 P\n同 P\n应邀 VV\n参加 VV\n中宣部 NR\n召开 VV\n的 DEC\n全国 JJ\n先进 JJ\n典型 NN\n座谈会 NN\n的 DEG\n军队 NN\n代表 NN\n徐洪刚 NR\n、 PU\n韩素云 NR\n、 PU\n李国安 NR\n、 PU\n邹延龄 NR\n、 PU\n第四军医大学 NR\n学员 NN\n二大队 NN\n代表 NN\n李尔青 NR\n以及 CC\n武警部队国旗护卫队 NR\n代表 NN\n王建华 NR\n座谈 VV\n时 LC\n， PU\n称赞 VV\n他们 PN\n的 DEG\n先进 JJ\n事迹 NN\n是 VC\n中华 NR\n民族 NN\n传统 JJ\n美德 NN\n和 CC\n我 PN\n党 NN\n我 PN\n军 NN\n优良 VA\n传统 VA\n的 DEC\n完美 NN\n结合 VV\n， PU\n体现 VV\n了 AS\n我 PN\n党 NN\n我军 NN\n全心全意 AD\n为 P\n人民 NN\n服务 VV\n的 DEC\n宗旨 NN\n， PU\n体现 VV\n了 AS\n与 P\n社会主义 NN\n市场 NN\n经济 NN\n相 AD\n适应 VV\n的 DEC\n时代 NN\n精神 NN\n。 PU\n于永波 NR\n指出 VV\n， PU\n我军 NN\n是 VC\n一 CD\n支 M\n英雄 NN\n模范 NN\n辈出 VV\n的 DEC\n军队 NN\n， PU\n用 P\n先进 JJ\n典型 JJ\n教育 NN\n部队 NN\n是 VC\n我军 NN\n政治 NN\n工作 NN\n的 DEG\n优良 JJ\n传统 NN\n。 PU\n他 PN\n说 VV\n， PU\n要 VV\n充分 AD\n发挥 VV\n先进 JJ\n典型 JJ\n的 DEG\n示范 NN\n、 PU\n激励 VV\n、 PU\n感召 NN\n作用 NN\n， PU\n在 P\n部队 NN\n营造 VV\n学习 VV\n先进 VA\n、 PU\n奋发 VV\n向上 VV\n的 DEC\n良好 JJ\n风气 NN\n。 PU\n要 VV\n把 BA\n向 P\n英雄 NN\n模范 NN\n学习 VV\n同 P\n做好 VV\n部队 NN\n的 DEG\n各 DT\n项 M\n工作 NN\n紧密 AD\n结合 VV\n起来 VV\n， PU\n爱岗 VV\n敬业 VV\n， PU\n在 P\n各自 PN\n的 DEG\n岗位 NN\n上 LC\n为 P\n军队 NN\n和 CC\n国防 NN\n建设 NN\n贡献 NN\n聪明才智 NN\n， PU\n按照 P\n江主席 NN\n“ PU\n五 CD\n句 M\n话 NN\n” PU\n的 DEG\n总 JJ\n要求 NN\n， PU\n推动 VV\n部队 NN\n全面 AD\n建设 VV\n。 PU\n总政 NN\n副主任 NN\n周子玉 NR\n、 PU\n唐天标 NR\n、 PU\n袁守芳 NR\n等 ETC\n参加 VV\n了 AS\n会见 NN\n。 PU" }

  it "should convert A#B into 'A B'" do
    str = '
    五#CD
    句#M
    话#NN
    ”#PU
    的#DEG
    总#JJ
    要求#NN
    ，#PU
    推动#VV
    部队#NN
    全面#AD
    建设#VV
    。#PU
    总政#NN
    副主任#NN
    周子玉#NR
    、#PU
    唐天标#NR
    、#PU
    袁守芳#NR
    等#ETC
    参加#VV
    了#AS
    会见#NN
    。#PU
    '

    str_expected = '
    五 CD
    句 M
    话 NN
    ” PU
    的 DEG
    总 JJ
    要求 NN
    ， PU
    推动 VV
    部队 NN
    全面 AD
    建设 VV
    。 PU
    总政 NN
    副主任 NN
    周子玉 NR
    、 PU
    唐天标 NR
    、 PU
    袁守芳 NR
    等 ETC
    参加 VV
    了 AS
    会见 NN
    。 PU
    '

    str.to_crf_input!.should == str_expected
    str.should == str_expected
  end

  it "should produces normalize text" do
    normalize(input_file, keep_bracket: true).should eql(normalized_text)
    normalize(input_file, keep_bracket: false).should eql(normalized_text_without_bracket)
  end

  it "should segment correctly" do
    # pending 'pass'
    path = store_result(normalized_text)
    segment(path)[0].should eql(segmented_text)

    path = store_result(normalized_text_without_bracket)
    segment(path)[0].should eql(segmented_text_without_bracket)
  end

  it "should postag correctly" do
    pending 'pass'
    path = store_result(segmented_text)
    postag(path)[0].should eql(postagged_text)
  end

  it "should linerize correctly" do
    postagged_text_01 = postagged_text
    postagged_text_01.linerize!.should eql(linerized_text)

    postagged_text_01.to_crf_input!.should eql(crf_input)
  end
end