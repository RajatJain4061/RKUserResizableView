# RKUserResizableView
RKUserResizableView is a user-resizable, user-repositionable UIView subclass built for iOS (Swift 3).


RKUserResizableView is a user-resizable, user-repositionable UIView subclass. It is modeled after the resizable image view from the Pages iOS app. Any UIView can be provided as the content view for the SPUserResizableView. As the view is respositioned and resized, setFrame: will be called on the content view accordingly.

Screenshot
----
![RKUserResizableViewScreenshot](/screenshot.png?raw=true "RKUserResizableView")

How To Use It
-------------

### Installation

Include RKUserResizableView.swift in your project.

### Setting up the RKUserResizableView

You'll need to construct a new instance of RKUserResizableView. Then, set the contentView on the RKUserResizableView to the view you'd like the user to interact with.

``` swift

     var currentlyEditingView:RKUserResizableView? = nil
     var lastEditedView:RKUserResizableView? = nil

     override func viewDidLoad() {
          super.viewDidLoad()

          // (1) Create a user resizable view with a simple red background content view.
          let gripFrame = CGRect(x: 50, y: 50, width: 200, height: 150)
          let userResizableView = RKUserResizableView(frame: gripFrame)
          userResizableView.delegate = self
          let contentView = UIView(frame: gripFrame)
          contentView.backgroundColor = UIColor.red
          userResizableView.contentView = contentView
          userResizableView.showEditingHandles()
          currentlyEditingView = userResizableView
          lastEditedView = userResizableView
          self.view.addSubview(userResizableView)

          // (2) Create a second resizable view with a UIImageView as the content.
          let imageFrame = CGRect(x: 50, y: 200, width: 200, height: 200)
          let imageResizableView = RKUserResizableView(frame: imageFrame)
          let imageView = UIImageView(image: UIImage(named: "smiley"))
          imageResizableView.contentView = imageView
          imageResizableView.delegate = self
          self.view.addSubview(imageResizableView)
     }
```

If you'd like to receive callbacks when the RKUserResizableView receives touchBegan:, touchesEnded: and touchesCancelled: messages, set the delegate on the RKUserResizableView accordingly. 

``` swift
userResizableView.delegate = self;
```

Then implement the following delegate methods.

``` swift
// Called when the resizable view receives touchesBegan: and activates the editing handles.
func userResizableViewDidBeginEditing(_ userResizableView: RKUserResizableView)

// Called when the resizable view receives touchesEnded: or touchesCancelled:
func userResizableViewDidEndEditing(_ userResizableView: RKUserResizableView)
```

By default, RKUserResizableView will show the editing handles (as seen in the screenshot above) whenever it receives a touch event. The editing handles will remain visible even after the userResizableViewDidEndEditing: message is sent. This is to provide visual feedback to the user that the view is indeed moveable and resizable. If you'd like to dismiss the editing handles, you must explicitly call hideEditingHandles().

The RKUserResizableView is customizable using the following properties:

``` swift
// Default is 48.0 for each.
var minWidth: CGFloat = 48.0
var minHeight: CGFloat = 48.0

// Defaults to YES. Disables the user from dragging the view outside the parent view's bounds.
var isPreventsPositionOutsideSuperview: Bool = true
```

For an example of how to use RKUserResizableView, please see the included example project.

## Acknowledgments

* Hat tip to Stephen Poletto [spoletto](https://github.com/spoletto)

