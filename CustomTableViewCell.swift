//
//  CustomTableViewCell.swift
//  Faby
//
//  Created by Batch - 2 on 22/01/25.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    // UI elements for the cell
    var cellImageView: UIImageView!
    var headingLabel: UILabel!
    var subheadingLabel: UILabel!
    
    // Initialization code
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialize the UI elements
        cellImageView = UIImageView()
        headingLabel = UILabel()
        subheadingLabel = UILabel()
        
        // Setup the properties of the elements
        setupCellImageView()
        setupHeadingLabel()
        setupSubheadingLabel()
    }
    
    // Configure image view
    private func setupCellImageView() {
        cellImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cellImageView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            cellImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            cellImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            cellImageView.widthAnchor.constraint(equalToConstant: 40),
            cellImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // Configure heading label
    private func setupHeadingLabel() {
        headingLabel.translatesAutoresizingMaskIntoConstraints = false
        headingLabel.font = UIFont.boldSystemFont(ofSize: 16)
        contentView.addSubview(headingLabel)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            headingLabel.leadingAnchor.constraint(equalTo: cellImageView.trailingAnchor, constant: 10),
            headingLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            headingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
    
    // Configure subheading label
    private func setupSubheadingLabel() {
        subheadingLabel.translatesAutoresizingMaskIntoConstraints = false
        subheadingLabel.font = UIFont.systemFont(ofSize: 12)
        subheadingLabel.textColor = .gray
        contentView.addSubview(subheadingLabel)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            subheadingLabel.leadingAnchor.constraint(equalTo: headingLabel.leadingAnchor),
            subheadingLabel.topAnchor.constraint(equalTo: headingLabel.bottomAnchor, constant: 5),
            subheadingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            subheadingLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    // Configure the cell with item data
    func configure(with item: Item) {
        headingLabel.text = item.name
        subheadingLabel.text = item.description // Access the 'details' property of Item
        cellImageView.image = Todbite.shared.image(for: item)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
