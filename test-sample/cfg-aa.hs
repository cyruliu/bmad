import Language.Dot (parseDot)

main = do
    dotFile <- readFile "strcpy.dot"
    case parseDot "output.dot" dotFile of
            Right dot -> putStrLn "Successfully parsed dot" >> print dot
            Left err -> print err
