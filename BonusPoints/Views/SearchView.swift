//
//  SearchView.swift
//  BonusPoints
//
//  Created by Lukas Marius Hoeschen on 23.04.26.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var dm: AppDataHandler
    
    @State private var searchText = ""
    
    var filteredTasks: [TaskStruct] {
        dm.family.tasks.flatMap({ $0.list }).filter { t in
            let matchesSearch = searchText.isEmpty ||
            t.name.localizedCaseInsensitiveContains(searchText)
            return matchesSearch
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if !filteredTasks.isEmpty {
                    Section {
                        ForEach(filteredTasks) { task in
                            TaskInListView(task: task)
                        }
                    } header: {
                        Text("Tasks")
                    }
                }
                if filteredTasks.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }.navigationTitle("Search")
                .searchable(text: $searchText)
        }
    }
    
    private func Summary(emoji: String, title: String, subTitle: String, detail: String?) -> some View {
        HStack {
            Text(emoji)
                .font(.system(size: 22))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.primary)
                Text(subTitle)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            if let detail {
                Text(detail)
                    .font(.system(size: 12))
                    .foregroundStyle(.tertiary)
            }
        }
    }
    
    private func listSummary(list: TaskList) -> some View {
        Summary(emoji: "", title: list.name, subTitle: "Tasks: \(list.list.count)", detail: nil)
    }
}


struct PreviewSection<Item: Identifiable, RowView: View, DetailView: View>: View {
    let title: String
    let items: [Item]
    let rowView: (Item) -> RowView
    let detailView: (Item) -> DetailView
    let maxItems: Int

    var body: some View {
        if !items.isEmpty {
            Section {
                ForEach(items.prefix(maxItems)) { item in
                    NavigationLink {
                        detailView(item)
                    } label: {
                        rowView(item)
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text("\(title) (\(items.count) results)")
            } footer: {
                if items.count > maxItems {
                    NavigationLink {
                        Form {
                            Section {
                                ForEach(items) { item in
                                    NavigationLink {
                                        detailView(item)
                                    } label: {
                                        rowView(item)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .navigationTitle(title)
                    } label: {
                        HStack {
                            Spacer()
                            Text("Show all results in \(title)")
                            Image(systemName: "chevron.forward")
                        }.font(.caption)
                        .foregroundStyle(.secondary)
                        .tint(.secondary)
                    }
                }
            }
        }
    }
}


#Preview {
    SearchView()
}
