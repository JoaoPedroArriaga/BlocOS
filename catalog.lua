-- catalog.lua - Catálogo dinâmico de apps do BlocOS
-- Edit este arquivo para adicionar/remover apps
-- A store baixa ele automaticamente!

return {
    -- App 1: Chat
    {
        name = "Chat BlocOS",
        desc = "Converse com outros usuários em tempo real",
        category = "Social",
        author = "BlocOS Team",
        size = "15KB",
        file = "chat.lua",
        icon = "💬",
        color = colors.cyan,
        version = "1.0.0",
        requirements = {"modem"}  -- Precisa de modem?
    },
    
    -- App 2: Monitor do Sistema
    {
        name = "System Monitor",
        desc = "Veja CPU, RAM e estatísticas",
        category = "Ferramentas",
        author = "BlocOS Team",
        size = "12KB",
        file = "monitor.lua",
        icon = "📊",
        color = colors.green,
        version = "1.0.0"
    },
    
    -- App 3: Calculadora
    {
        name = "Calculadora",
        desc = "Faça cálculos básicos e avançados",
        category = "Ferramentas",
        author = "BlocOS Team",
        size = "8KB",
        file = "calc.lua",
        icon = "🧮",
        color = colors.yellow,
        version = "1.0.0"
    },
    
    -- App 4: Jogo da Velha
    {
        name = "Jogo da Velha",
        desc = "Tic-tac-toe para dois jogadores",
        category = "Jogos",
        author = "Community",
        size = "10KB",
        file = "velha.lua",
        icon = "🎮",
        color = colors.purple,
        version = "1.0.0"
    },
    
    -- App 5: Configurações
    {
        name = "Configurações",
        desc = "Ajustes do BlocOS",
        category = "Sistema",
        author = "BlocOS Team",
        size = "20KB",
        file = "settings.lua",
        icon = "⚙",
        color = colors.red,
        version = "1.0.0",
        system = true  -- App do sistema
    },
    
    -- App 6: Gerenciador de Arquivos
    {
        name = "File Manager",
        desc = "Navegue e gerencie arquivos",
        category = "Ferramentas",
        author = "BlocOS Team",
        size = "18KB",
        file = "files.lua",
        icon = "📁",
        color = colors.orange,
        version = "1.0.0"
    },
    
    -- App 7: Clima (exemplo de app que pode ser adicionado depois)
    -- {
    --     name = "Weather",
    --     desc = "Previsão do tempo",
    --     category = "Ferramentas",
    --     author = "Community",
    --     size = "14KB",
    --     file = "weather.lua",
    --     icon = "☀️",
    --     color = colors.cyan,
    --     version = "1.0.0"
    -- },
    
    -- Adicione novos apps AQUI! Basta copiar o formato acima
}