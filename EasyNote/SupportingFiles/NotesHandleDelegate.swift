//
//  NotesHandleDelegate.swift
//  EasyNote
//
//  Created by Sergey Golovin on 25.09.2021.
//  Copyright © 2021 GoldenWindGames LLC. All rights reserved.
//

import Foundation

protocol  NotesHandleDelegate {
    func saveChanges(note: Note)
    func deleteNote()
}
