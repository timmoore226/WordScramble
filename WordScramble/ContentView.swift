//
//  ContentView.swift
//  WordScramble
//
//  Created by Timothy Moore on 7/6/20.
//  Copyright © 2020 Timothy Moore. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            VStack {
                Button("Restart Game") {
                    self.startGame()
                }
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)
                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
            }
            .navigationBarTitle(rootWord)
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func addNewWord() {
        // lowercase and trim the word
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        // exit if the remaining string is empty
        guard answer.count > 0 else {
            return
        }
        // validation
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original.")
            return
        }
        guard isPossible(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up!")
            return
        }
        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "That isn't even a real word.")
            return
        }
        
        usedWords.insert(answer, at: 0)
        newWord = ""
    }
    
    func startGame() {
        // clear used word list
        usedWords.removeAll()
        
        // find the url for start.txt in our bundle
        if let startWordsUrl = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // load start.txt into a string
            if let startWords = try? String.init(contentsOf: startWordsUrl) {
                // split the string
                let allWords = startWords.components(separatedBy: "\n")
                
                // pick a random word or use 'ringworm' as default
                rootWord = allWords.randomElement() ?? "ringworm"
                
                // everything must have work, so exit
                return
            }
            // if here, there was a big problem so trigger the error
            fatalError("Could not load the start.txt from the bundle.")
        }
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word) && !word.contains(rootWord)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        if word.count < 3 {
            return false
        }
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
