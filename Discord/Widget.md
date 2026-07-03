## Criação de Widget (Fácil)

Este script realiza a maior parte do trabalho de criação do widget para você, caso tenha achado os tutoriais manuais muito difíceis de seguir.

Como usar:
1. Acesse o [Portal do Desenvolvedor do Discord](https://discord.com/developers/applications)
2. Pressione Ctrl+Shift+I para abrir as Ferramentas de Desenvolvedor (DevTools)
3. Vá para a aba `Console`
4. Cole o código a seguir e pressione Enter:
<details>
	<summary>Clique para expandir</summary>
  
```js
let wpRequire = webpackChunkdiscord_developers.push([[Symbol()], {}, r => r]);
webpackChunkdiscord_developers.pop();

let ApexStore = Object.values(wpRequire.c).find(x => x?.exports?.A?.createOverride).exports.A;
let UserStore = Object.values(wpRequire.c).find(x => x?.exports?.A?.__proto__?.getCurrentUser).exports.A;
let FluxDispatcher = Object.values(wpRequire.c).find(x => x?.exports?.A?.__proto__?.flushWaitQueue).exports.A;
let api = Object.values(wpRequire.c).find(x => x?.exports?.Bo?.get).exports.Bo;
let globalCopy = navigator.userAgent.includes("Firefox") ? navigator.clipboard.writeText.bind(navigator.clipboard) : copy
const sleep = ms => new Promise(resolve => setTimeout(resolve, ms))

const userId = UserStore.getCurrentUser().id
console.log("[Criador de Widget] Criando um novo aplicativo... Resolva o captcha caso seja solicitado")
const appRes = await api.post({url: "/applications", body: {name: "Meu Novo Widget", team_id: null}})
FluxDispatcher.dispatch({type: "APPLICATION_CREATE_SUCCESS", application: appRes.body})
const appId = appRes.body.id

console.log("[Criador de Widget] Ativando o Social SDK...")
await api.post({url: `/applications/${appId}/social-sdk/enable`, body: {"name":"a","business_email":"foo@bar.com","game_or_studio_name":"a","game_or_studio_url":"","email_updates_consent":false,"country_or_region":"United States","title_role":"Founder","target_platforms":[],"form_type":"Dev Solutions","sfdc_leadsource":"Dev Portal","utm_campaign":"SDK Enable Form"}})

console.log("[Criador de Widget] Criando um novo widget...")
const configRes = await api.post({url: `/applications/${appId}/widget-configs`, body: {display_name: "Meu Widget"}})
const configId = configRes.body.config_id
await api.patch({url: `/applications/${appId}/widget-configs/${configId}`, body: {"surfaces":{"widget_top":{"layout":"widget_top_hero","components":{"hero_image":{"fields":{"image":{"presentation_type":"image","value_type":"data","value":"altere para uma imagem"}}},"title":{"fields":{"text":{"presentation_type":"text","value_type":"custom_string","value":"algum título aqui"}}}}},"widget_bottom":{"layout":"widget_bottom_stats","components":{"stat_1":{"fields":{"value":{"presentation_type":"text","value_type":"custom_string","value":"texto 1 aqui"},"label":{"presentation_type":"text","value_type":"custom_string","value":"rótulo 1 aqui"}}},"stat_2":{"fields":{"value":{"presentation_type":"text","value_type":"custom_string","value":"texto 2 aqui"},"label":{"presentation_type":"text","value_type":"custom_string","value":"rótulo 2 aqui"}}},"stat_3":{"fields":{"value":{"presentation_type":"text","value_type":"custom_string","value":"texto 3 aqui"},"label":{"presentation_type":"text","value_type":"custom_string","value":"rótulo 3 aqui"}}},"stat_4":{"fields":{"value":{"presentation_type":"text","value_type":"custom_string","value":"texto 4 aqui"},"label":{"presentation_type":"text","value_type":"custom_string","value":"rótulo 4 aqui"}}},"stat_5":{"fields":{"value":{"presentation_type":"text","value_type":"custom_string","value":"texto 5 aqui"},"label":{"presentation_type":"text","value_type":"custom_string","value":"rótulo 5 aqui"}}},"stat_6":{"fields":{"value":{"presentation_type":"text","value_type":"custom_string","value":"texto 6 aqui"},"label":{"presentation_type":"text","value_type":"custom_string","value":"rótulo 6 aqui"}}}}},"add_widget_preview":{"layout":"add_widget_preview_hero","components":{"hero_image":{"fields":{"image":{"presentation_type":"image","value_type":"data","value":"altere para uma imagem"}}}}}}}})
await api.post({url: `/applications/${appId}/widget-configs/${configId}/publish`})

console.log("[Criador de Widget] Adicionando o widget ao perfil...")
await api.patch({url: `/applications/${appId}`, body: {redirect_uris: ["https://discord.com"]}})
await api.post({url: `/oauth2/authorize?client_id=${appId}&response_type=token&scope=sdk.social_layer_presence`, body: {authorize: true}})
const profileRes = await api.get({url: `/users/${userId}/profile`})
const existingWidgets = profileRes.body.widgets
existingWidgets.unshift({"data":{"type":"application","application_id":appId}})
await api.put({url: `/users/@me/widgets`, body: {"widgets": existingWidgets}})

console.log("[Criador de Widget] Obtendo o token do bot... Digite seu código 2FA caso seja solicitado")
const botTokenRes = await api.post({url: `/applications/${appId}/bot/reset`})
const botToken = botTokenRes.body.token

globalCopy(`Invoke-RestMethod -Method PATCH -Headers @{"Content-Type"="application/json"; "Authorization"="Bot ${botToken}";"User-Agent"="DiscordBot (https://github.com/discord/discord-api-docs, 1.0.0)"} -Uri https://discord.com/api/v9/applications/${appId}/users/${userId}/identities/0/profile -Body '${JSON.stringify({data: {dynamic: []}})}'`)
console.log("[Criador de Widget] Um comando foi copiado para sua área de transferência. Cole-o no terminal do seu PC e pressione Enter.")

ApexStore.createOverride("2026-03-widget-config-editor", 1)
document.querySelector(`a[href="/developers/applications/${appId}"]`).click()
while(!document.querySelector(`a[href="/developers/applications/${appId}/widget"]`)) {
    await sleep(100)
}
document.querySelector(`a[href="/developers/applications/${appId}/widget"]`).click()
console.log("[Criador de Widget] Depois disso, você poderá editar seu widget nesta página!")
```
</details>

5. Se solicitado, complete o captcha e insira seu código 2FA
6. Assim que terminar, o script copiará um comando do PowerShell para sua área de transferência
7. Abra um terminal do PowerShell clicando com o botão direito no botão do Windows (canto inferior esquerdo) e selecionando "PowerShell" ou "Terminal"

<img width="428" height="423" alt="PowerShell" src="https://gist.github.com/user-attachments/assets/872259fb-9f05-40ef-b140-3dadb23379c6" />

8. Clique com o botão direito ou Ctrl+V no terminal para colar o comando copiado
9. Pressione Enter para executá-lo
10. Feche o terminal
11. Volte para a aba do navegador para editar seu widget

O script adiciona automaticamente o novo widget ao seu perfil do Discord.

## Perguntas Frequentes (FAQ)

> ## Não consigo ver o Editor de Widgets

Execute este script no console:

<details>
	<summary>Clique para expandir</summary>

```js
let wpRequire = webpackChunkdiscord_developers.push([[Symbol()], {}, r => r]);
webpackChunkdiscord_developers.pop();

let ApexStore = Object.values(wpRequire.c).find(x => x?.exports?.A?.createOverride).exports.A;
ApexStore.createOverride("2026-03-widget-config-editor", 1)
```
</details>

em seguida, navegue até o seu aplicativo e vá em Games -> Widget

<img width="345" height="304" alt="GamesWidgets" src="https://gist.github.com/user-attachments/assets/acb97025-a7e1-4947-b62d-bde82e1013c3" />

> ## Como adiciono imagens ao widget?

Certifique-se de que o `Value Type` esteja definido como `Application Asset` e, então, use este botão para fazer o upload e selecionar uma imagem:

<img width="564" height="438" alt="Assets" src="https://gist.github.com/user-attachments/assets/51480e7f-b04a-4b66-8f6e-fcdb61de0fdf" />

> ## Outras pessoas não conseguem ver meu widget!
### 1. Você provavelmente esqueceu de publicar seu widget.
Acesse o [Portal do Desenvolvedor](https://discord.com/developers/applications), abra o Editor de Widgets do seu aplicativo e clique em [Publicar] no canto superior direito.
### 2. Suas estatísticas ainda estão sendo sincronizadas.
Se você consegue ver seu widget, mas há uma pequena caixa com bordas abaixo dele informando que os dados ainda estão sendo sincronizados. Se essa caixa continua aparecendo, somente você verá.
> ## Mais pessoas podem usar meu widget?
Infelizmente, o Discord limitou temporariamente a capacidade de usar widgets criados por terceiros. Somente o proprietário do aplicativo (ou outros membros da equipe proprietária do aplicativo) pode usá-lo em seu perfil. Enquanto houver widgets que não foram criados por você em seu painel de widgets, você não poderá salvar ou alterar nenhum widget em seu perfil.

Você ainda pode compartilhar seu widget em #widget-vitrine em nosso servidor do Discord.
Sinta-se à vontade para publicar a aparência do seu widget⁠ para que outros se inspirem.

Você também pode usar outras plataformas para que outras pessoas possam configurá-lo por conta própria! 

> ## Não consigo ver meu widget no botão "Adicionar Widgets"
Execute o seguinte código no seu console **com o ID do seu bot/app**:
<details>
	<summary>Clique para expandir</summary>

```js
let _mods=webpackChunkdiscord_app.push([[Symbol()],{},e=>e.c]);webpackChunkdiscord_app.pop();
let findByProps=(...e)=>{for(let t of Object.values(_mods))try{if(!t.exports||t.exports===window)continue;if(e.every(e=>t.exports?.[e]))return t.exports;for(let r in t.exports)if(e.every(e=>t.exports?.[r]?.[e])&&"IntlMessagesProxy"!==t.exports[r][Symbol.toStringTag])return t.exports[r]}catch{}};

// Altere APPLICATION_ID para o ID do seu app
findByProps("getFeaturedApplicationIds").getFeaturedApplicationIds().push("APPLICATION_ID");
```

</details>

> ## Meu widget ainda não aparece!
O Discord ainda está liberando o recurso de widgets para os usuários.
Infelizmente, não há nada que você possa fazer para corrigir isso agora.