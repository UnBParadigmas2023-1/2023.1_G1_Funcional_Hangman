module Logic where

import System.Console.ANSI
import System.Exit(exitSuccess)

import Data.Char (toUpper)
import Interface (logoJogo, telaFim)
import Words (getInputValido)

-- | Função que inicia o jogo
jogo :: String -> Int -> IO ()
jogo palavraSecreta chances = do
    -- passar a palavraSecreta para maiuscula e chamar a função jogar
    jogar (map toUpper palavraSecreta) (replicate (length palavraSecreta) '-') [] chances

-- | Função principal que recebe as tentativas do usuário até acertar a palavra
jogar :: String -> String -> [Char] -> Int -> IO ()
jogar palavraSecreta estadoAtual letrasErradas chances = do
    if (chances == 0) then telaFim palavraSecreta 1
    else do
        -- imprime as letras erradas
        setSGR [SetColor Foreground Vivid White]
        logoJogo
        setSGR [SetColor Background Vivid Red]
        putStr "Letras erradas: "
        putStr $ filter (`notElem` palavraSecreta) letrasErradas
        setSGR [Reset]
        putStr "\n"
        
        -- imprime quantidade de chances
        setSGR [SetColor Foreground Vivid White]
        setSGR [SetColor Background Vivid Red]
        putStr "Chances: "
        putStr (show chances)
        setSGR [Reset]
        putStrLn "\n"

        -- imprime a palavra secreta
        setSGR [SetColor Foreground Vivid Black]
        setSGR [SetColor Background Vivid White] 
        putStr "Tente adivinhar a palavra: "
        putStr estadoAtual
        setSGR [Reset]
        putStrLn "\n" 

        -- verifica se o usuário acertou a palavra
        if all (`elem` estadoAtual) palavraSecreta then
            telaFim palavraSecreta 0
        -- se não acertou, pede uma nova tentativa
        else do
            setSGR [SetColor Foreground Vivid White]
            putStrLn "Escolha uma letra:"
            palavraTeste <- getLine
            let palavra = map toUpper palavraTeste
            let (novoEstado, novasLetrasErradas) = estadoPalavra palavraSecreta palavra estadoAtual letrasErradas
            -- chama a função jogar novamente com o novo estado recursivo
            jogar palavraSecreta novoEstado novasLetrasErradas (chances - 1)

-- | Função que retorna a palavra secreta com as letras corretas preenchidas e os traços para as letras não acertadas
estadoPalavra :: String -> String -> String -> [Char] -> (String, [Char])
estadoPalavra secreta palavra estadoAnterior letrasErradas =
  -- zip secreta estadoAtual -> cria uma lista de tuplas com as letras da palavra secreta e as letras acertadas
  let estadoAtual = [ if c `elem` palavra then c else estadoAnterior!!i | (c,i) <- zip secreta [0..] ]
  -- filtra as letras erradas
      novasLetrasErradas = filter (`notElem` estadoAnterior) palavra
  -- retorna a palavra secreta com as letras corretas preenchidas e os traços para as letras não acertadas
  in (map displayChar (zip secreta estadoAtual), letrasErradas ++ novasLetrasErradas) 
  where 
    displayChar (c1, c2)
      | c1 == c2 = c1
      | otherwise = '-'

setDificuldade :: IO Int
setDificuldade = do
    clearFromCursorToScreenBeginning
    logoJogo
    putStrLn "\nDificuldades:"
    putStrLn "[1] Fácil"
    putStrLn "[2] Moderado"
    putStrLn "[3] Difícil"
    putStrLn "\nEscolha a dificuldade: "
    dificuldade<-getInputValido 3
    let chances = case dificuldade of
                    1 -> 15
                    2 -> 10
                    3 -> 7
    return chances

-- | Função que indica quais letras em uma string ocorrem na segunda string, se as letras forem diferente preenche com um tracinho
match :: String -> String -> String
match xs ys =
   [if elem x ys then x else '-' | x <- xs]
