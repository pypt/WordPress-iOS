import UIKit

class CreateNewBlog2ViewController: CreateAccountAndBlogViewController
{
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        hideNonRelevantFields()
        customizeRelevantFields()
    }
    
    override func configurePasswordField(x: CGFloat, y: CGFloat, textFieldHeight: CGFloat) {
        passwordField.frame = CGRectIntegral(CGRect(x: x, y: y, width: CreateAccountAndBlogTextFieldWidth, height: 0))
    }
    
    override func isUsernameUnderFiftyCharacters() -> Bool {
        return true
    }
    
    override func isPasswordFilled() -> Bool {
        return true
    }
    
    override func isEmailedFilled() -> Bool {
        return true
    }
    
    override func actionNow() {
        createBlog()
    }
    
    func hideNonRelevantFields() {
        emailField.hidden = true
        passwordField.hidden = true
        onePasswordButton.hidden = true
        helpButton.hidden = true
        TOSLabel.hidden = true
    }
    
    func customizeRelevantFields() {
        let titleAttributes = WPNUXUtility.titleAttributesWithColor(UIColor.whiteColor()) as! [String : AnyObject]
        let titleAttributedText = NSAttributedString(string: NSLocalizedString("Create WordPress.com blog", comment: "Create WordPress.com blog"), attributes: titleAttributes)
        titleLabel.attributedText = titleAttributedText
        
        // username
        let editImage = UIImage(named: "icon-email-field")
        let editImageView = UIImageView(image: editImage)
        usernameField.leftView = editImageView
        usernameField.placeholder = NSLocalizedString("Title", comment: "Title")
    }
}
