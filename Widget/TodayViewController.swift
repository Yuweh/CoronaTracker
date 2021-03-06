//
//  TodayViewController.swift
//  CoronaTrackerWidget
//
//  Created by Piotr Ożóg on 12/03/2020.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {

	@IBOutlet var worldwideTitleLabel: UILabel!
    @IBOutlet var confirmedCountLabel: UILabel!
    @IBOutlet var recoveredCountLabel: UILabel!
    @IBOutlet var deathsCountLabel: UILabel!
	@IBOutlet var dataViews: [UIView]!
	@IBOutlet var dataLabels: [UILabel]!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
	@IBOutlet var updateTimeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeView()

		DataManager.instance.load(reportsOnly: true) { [weak self] success in
			self?.update(report: DataManager.instance.worldwideReport)
		}
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        activityIndicatorView.startAnimating()
		updateTimeLabel.isHidden = true
        DataManager.instance.download { [weak self] success in
            completionHandler(success ? NCUpdateResult.newData : NCUpdateResult.failed)
            DataManager.instance.load(reportsOnly: true) { [weak self] success in
                self?.activityIndicatorView.stopAnimating()
				self?.updateTimeLabel.isHidden = false
                self?.update(report: DataManager.instance.worldwideReport)
            }
        }
    }

	private func initializeView() {
		dataViews.forEach { view in
			view.layer.cornerRadius = 8
//			view.isHidden = true
		}
		dataLabels.forEach { label in
			label.textColor = .white
		}
		updateTimeLabel.textColor = SystemColor.secondaryLabel
		if #available(iOSApplicationExtension 13.0, *) {
			activityIndicatorView.style = .medium
		}
	}

    private func update(report: Report?) {
        guard let report = report else {
            return
        }

		view.transition { [weak self] in
			self?.confirmedCountLabel.text = report.stat.confirmedCountString
			self?.recoveredCountLabel.text = report.stat.recoveredCountString
			self?.deathsCountLabel.text = report.stat.deathCountString
			self?.updateTimeLabel.text = report.lastUpdate.relativeTimeString
		}

//		dataViews.forEach({ $0.isHidden = false })
    }
}
