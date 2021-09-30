//
//  NotesViewController.swift
//  EasyNote
//
//  Created by Sergey Golovin on 25.09.2021.
//  Copyright © 2021 GoldenWindGames LLC. All rights reserved.
//

import UIKit
import CoreData

let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

private let reuseIdentifier = "noteCell"
private let toDetailSegueID = "toDetailVC"
private let editNoteSegueID = "editNote"

private let numberOfCellsInRow: CGFloat = 2
private let insetWidth: CGFloat = 20
private let sectionInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

private var editMode = false
private var indexPathForEditingNote: IndexPath?
var notesArray = [Note]()

class NotesViewController: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarTextColor()
        loadNotes()
        createTestNotes()
    }
    
    @IBAction func addNewNoteBtnPressed(_ sender: UIBarButtonItem) {
        editMode = false
        performSegue(withIdentifier: toDetailSegueID, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == editNoteSegueID {
            if let vc = segue.destination as? DetailViewController {
                vc.notesHandleDelegate = self
                vc.title = "Edit note"

                if indexPathForEditingNote != nil {
                    vc.note = notesArray[indexPathForEditingNote!.row]
                }
            }
        } else if segue.identifier == toDetailSegueID {
            if let vc = segue.destination as? DetailViewController {
                vc.notesHandleDelegate = self
                vc.title = "Add new note"
            }
        }
    }
    
    // Creates test note when app starts for the first time
    private func createTestNotes() {
        var localNotesArray = [Note]()
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        do {
            localNotesArray = try context.fetch(request)
        } catch {
            print("Load error \(error)")
        }
        if localNotesArray.isEmpty {
            let firstNote = Note(context: context)
            firstNote.title = "Note one"
            firstNote.body = "First note"
            firstNote.image = UIImage(systemName: "photo")?.pngData()
            notesArray.append(firstNote)
            collectionView.reloadData()
        }
    }
}

// MARK: UICollectionViewDataSource

extension NotesViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        notesArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? NoteCell else { return UICollectionViewCell() }
        cell.layer.borderWidth = 2
        cell.layer.borderColor = #colorLiteral(red: 1, green: 0.04167353739, blue: 0.0673128325, alpha: 1)
        let note = notesArray[indexPath.row]
        cell.noteTitle.text = note.title
        cell.noteBody.text = note.body
        if let imageData = note.image {
            cell.noteImage.image = UIImage(data: imageData)
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        editMode = true
        indexPathForEditingNote = indexPath
        performSegue(withIdentifier: editNoteSegueID, sender: self)
    }
}

extension NotesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let insetsWidth = insetWidth * (numberOfCellsInRow + 1)
        let widthForCells = collectionView.frame.width - insetsWidth
        let cellWith = widthForCells / numberOfCellsInRow
        
        return CGSize(width: cellWith, height: cellWith)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return insetWidth
    }
}

// MARK: - Set NavigationBar TextColor

extension NotesViewController {
    private func setNavigationBarTextColor() {
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.standardAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        } else {
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        }
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}

// MARK: CoreData Methods

extension NotesViewController {
    private func saveNotes() {
        do {
            try context.save()
        } catch {
            print("Save error \(error)")
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    private func loadNotes() {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        do {
            notesArray = try context.fetch(request)
        } catch {
            print("Load error \(error)")
        }
    }
}

// MARK: NotesHandleDelegate Methods

extension NotesViewController: NotesHandleDelegate {
    func saveChanges(note: Note) {
        if editMode {
            guard let index = indexPathForEditingNote?.row else { return }
            notesArray[index] = note
            saveNotes()
        } else {
            notesArray.append(note)
            saveNotes()
        }
    }
    
    func deleteNote() {
        guard let index = indexPathForEditingNote?.row else { return }
        context.delete(notesArray[index])
        notesArray.remove(at: index)
        saveNotes()
    }
}
