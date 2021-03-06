import Hangouts

let sem = DispatchSemaphore(value: 0)
print("Initializing...")

// Authenticate and initialize the Hangouts client.
// Build the user and conversation lists.
var client: Client!
var userList: UserList!
var conversationList: ConversationList!

AuthenticatorCLI.authenticateClient {
	client = Client(configuration: $0)
	
	client.buildUserConversationList {
		userList = $0; conversationList = $1
		print("Obtained userList \(userList) and conversationList! \(conversationList)")
		sem.signal()
	}
}
_ = sem.wait(timeout: DispatchTime.distantFuture)
print("Continuing...")

print(conversationList.all_conversations.map { $0.conversation.conversationId })

// Start with the constant strings up here.
let str1 = "Parrot is not yet ready as a CLI tool."
let str2 = "Press ESC to exit."


// Launch an encapsulated interactive Terminal.
Terminal.interactive {
	
	// A quick macro that will let us get the padded 1/3 and 2/3 width of the screen.
	// Yes, it's disgusting. Here's what it does:
	//
	// 1. Obtain the current terminal frame.
	// 2. Slice its first third.
	// 3. Pad it by 2 lines horizontally.
	// 4. Squash it down 2 lines vertically.
	//
	// The second macro does the same after calculating the 2/3 slice of the screen.
	// The third macro simply provides a single line header at the top.
	let g: (Void) -> Frame = {
		return shift(f: pad(frame: slice(s: (x: 0.33, y: 1.00), Terminal.size()), (2, 0)), (0, 2))
	}
	let f: (Void) -> Frame = {
		var r = slice(s: (x: 0.33, y: 1.00), Terminal.size())
		var q = slice(s: (x: 0.66, y: 1.00), Terminal.size())
		q.p.x += r.s.w + 1
		q = shift(f: q, (0, 2))
		return q
	}
	let t: (Void) -> Frame = {
		return (p: (x: 0, y: 0), s: (w: Terminal.size().s.w, h: 1))
	}
	
	var sidebar = Canvas(g())
	sidebar.border = Border.`default`()
	sidebar.borderColor = ColorPair(4, colors: (.Magenta, .Black))
	
	// Write our three strings by centering them with specific colors.
	sidebar.redraw = { c in
		
		// Readjust the size of the canvas.
		let str3 = "\(c.frame)"
		c.frame = g()
		
		// Redraw all our strings.
		_ = c.write(string: str2,
			point: (center(item: c.frame.s.w, str2.characters.count), center(item: c.frame.s.h, 0) + 0),
			colors: ColorPair(2, colors: (.Black, .Blue)))
		_ = c.write(string: str3,
			point: (center(item: c.frame.s.w, str3.characters.count), center(item: c.frame.s.h, 0) + 1),
			colors: ColorPair(3, colors: (.Black, .Yellow)))
	}
	
	var content = Canvas(f())
	content.border = Border.`default`()
	content.borderColor = ColorPair(4, colors: (.Magenta, .Black))
	
	// Write our three strings by centering them with specific colors.
	content.redraw = { c in
		
		// Readjust the size of the canvas.
		let str3 = "Debug[size: \(c.frame)]"
		c.frame = f()
		
		// Redraw all our strings.
		_ = c.write(string: str1,
			point: (center(item: c.frame.s.w, str1.characters.count), center(item: c.frame.s.h, 0) + 0),
			colors: ColorPair(1, colors: (.Black, .Red)))
		_ = c.write(string: str3,
			point: (center(item: c.frame.s.w, str3.characters.count), center(item: c.frame.s.h, 0) + 1),
			colors: ColorPair(3, colors: (.Black, .Yellow)))
	}
	
	let title = "PARROT - HANGOUTS"
	var header = Canvas(t())
	header.redraw = { c in
		c.frame = t()
		_ = c.write(string: title,
			point: (center(item: c.frame.s.w, title.characters.count), center(item: c.frame.s.h, 0) + 0),
			colors: ColorPair(6, colors: (.Black, .White)))
	}
	
	// End the program when ESC is pressed.
	Terminal.bell()
	Terminal.wait(key: KeyCode(27))
}
