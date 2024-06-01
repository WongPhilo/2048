package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.input.keyboard.FlxKeyboard;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class PlayState extends FlxState
{
	// Private groups
	private var board:Array<Int>;
	private var _texts:Array<FlxText>;

	// Text
	private var turntext:FlxText;
	private var scoretext:FlxText;
	private var overtext:FlxText;

	// Buttons
	private var reset:FlxButton;
	private var cont:FlxButton;

	// Variables
	private var gameover:Bool;
	private var continued:Bool;
	private var turns:Int;
	private var score:Int;
	private var won:Bool;

	/**
	 * Creates and initializes a new game state.
	 */
	override public function create():Void
	{
		super.create();
		board = new Array<Int>();
		_texts = new Array<FlxText>();
		score = 0;
		turns = -1;
		gameover = false;
		continued = false;

		var textX = 10;
		var textY = 10;
		var count = 0;

		for (i in 0...4)
		{
			textX = 10;
			for (j in 0...4)
			{
				board[count] = 0;
				var _text = new FlxText(textX, textY, Std.string(0), 15);
				add(_text);
				_texts.push(_text);
				textX += 50;
				count++;
			}
			textY += 50;
		}

		turntext = new FlxText(185, 20, "Turns: " + Std.string(turns), 15);
		scoretext = new FlxText(185, 40, "Score: " + Std.string(score), 15);
		add(turntext);
		add(scoretext);

		addATwo();
	}

	/**
	 * Adds a two to a random blank tile. 
	 */
	private function addATwo()
	{
		var indices = new Array<Int>();
		turns++;
		turntext.text = "Turns: " + Std.string(turns);
		while (turntext.size > 15)
		{
			turntext.size--;
		}

		while (turntext.size < 15)
		{
			turntext.size++;
		}

		for (i in 0...board.length)
		{
			if (board[i] == 0)
			{
				indices.push(i);
			}
			else if (board[i] >= 2048 && continued == false)
			{
				gameover = true;
				overtext = new FlxText(FlxG.width / 2, 120, "You won!", 32);
				overtext.x -= overtext.width / 2;
				overtext.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.GREEN, 2, 1);
				add(overtext);
				reset = new FlxButton(FlxG.width / 2 - 90, 165, "Reset?", resetCallback.bind());
				add(reset);
				cont = new FlxButton(FlxG.width / 2, 165, "Continue?", continueCallback.bind());
				add(cont);
			}
		}

		if (indices.length == 0)
		{
			gameover = true;
			overtext = new FlxText(FlxG.width / 2, 120, "Game over!", 32);
			overtext.x -= overtext.width / 2;
			overtext.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.RED, 2, 1);
			add(overtext);
			reset = new FlxButton(FlxG.width / 2 - 40, 165, "Reset?", resetCallback.bind());
			add(reset);
		}
		else
		{
			var rand = Std.int(Math.random() * indices.length);
			board[indices[rand]] = 2;
			drawBoard();
		}
	}

	/**
	 * Resets the game state, either after a game over or advancing to a new level.
	 */
	function resetCallback():Void
	{
		gameover = false;
		continued = false;
		board = new Array<Int>();
		score = 0;
		turns = -1;

		var textX = 10;
		var textY = 10;
		var count = 0;

		for (v in _texts)
		{
			v.text = Std.string(0);
			count++;
		}

		for (i in 0...16)
		{
			board[i] = 0;
		}

		overtext.destroy();
		reset.destroy();
		if (cont != null) {
			cont.destroy();
		}
		turntext.destroy();
		scoretext.destroy();

		turntext = new FlxText(185, 20, "Turns: " + Std.string(turns), 15);
		scoretext = new FlxText(185, 40, "Score: " + Std.string(score), 15);
		add(turntext);
		add(scoretext);

		addATwo();
	}

	/**
	 * Simple callback, where the player signals their intent to continue.
	 */
	function continueCallback():Void
	{
		gameover = false;
		continued = true;
		overtext.destroy();
		reset.destroy();
		cont.destroy();
	}

	/**
	 * Draws the tiles. 
	 */
	private function drawBoard()
	{
		for (i in 0..._texts.length)
		{
			var val:String = Std.string(board[i]);
			var storedX = _texts[i].x;
			var storedY = _texts[i].y;
			_texts[i].destroy();
			_texts[i] = new FlxText(_texts[i].x, _texts[i].y, val, 15);
			while (_texts[i].size > 15)
			{
				_texts[i].size--;
			}

			while (_texts[i].size < 15)
			{
				_texts[i].size++;
			}

			add(_texts[i]);
		}
	}

	/**
	 * Checks for user input.
	 */
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (!gameover)
		{
			if (FlxG.keys.justPressed.W)
			{
				slideUp();
			}

			if (FlxG.keys.justPressed.A)
			{
				slideLeft();
			}

			if (FlxG.keys.justPressed.S)
			{
				slideDown();
			}

			if (FlxG.keys.justPressed.D)
			{
				slideRight();
			}
		}
	}

	/**
	 * Slides and merges the tiles.
	 * @param list 			The array of which you wish to slide.
	 * @return Array<Int> 	The slided array.
	 */
	private function slide(list:Array<Int>):Array<Int>
	{
		for (i in 0...list.length)
		{
			var cur = list[i];
			var j = i + 1;
			while (list[j] == 0)
			{
				j++;
			}

			if (j < list.length)
			{
				if (cur == 0)
				{
					cur = list[j];
					list[j] = 0;
				}
				else if (cur == list[j])
				{
					cur += list[j];
					score += cur;
					scoretext.text = "Score: " + Std.string(score);
					while (scoretext.size > 15)
					{
						scoretext.size--;
					}

					while (scoretext.size < 15)
					{
						scoretext.size++;
					}

					list[j] = 0;
				}
			}

			list[i] = cur;
		}

		return list;
	}
	
	/**
	 * Slides horizontally.
	 */
	private function slideLeft()
	{
		for (i in 0...4)
		{
			var arr = new Array<Int>();
			for (j in 0...4)
			{
				arr[j] = board[4 * i + j];
			}

			arr = slide(arr);

			for (j in 0...4)
			{
				board[4 * i + j] = arr[j];
			}
		}

		addATwo();
	}

	/**
	 * Slides vertically.
	 */
	private function slideUp()
	{
		for (i in 0...4)
		{
			var arr = new Array<Int>();
			for (j in 0...4)
			{
				arr[j] = board[4 * j + i];
			}

			arr = slide(arr);

			for (j in 0...4)
			{
				board[4 * j + i] = arr[j];
			}
		}

		addATwo();
	}

	/**
	 * Slides horizontally, but in reverse to provide the desired effect.
	 */
	private function slideRight()
	{
		for (i in 0...4)
		{
			var arr = new Array<Int>();
			for (j in 0...4)
			{
				arr[j] = board[4 * i + j];
			}

			arr.reverse();
			arr = slide(arr);
			arr.reverse();

			for (j in 0...4)
			{
				board[4 * i + j] = arr[j];
			}
		}

		addATwo();
	}

	/**
	 * Slides vertically, but in reverse to provide the desired effect.
	 */
	private function slideDown()
	{
		for (i in 0...4)
		{
			var arr = new Array<Int>();
			for (j in 0...4)
			{
				arr[j] = board[4 * j + i];
			}

			arr.reverse();
			arr = slide(arr);
			arr.reverse();

			for (j in 0...4)
			{
				board[4 * j + i] = arr[j];
			}
		}

		addATwo();
	}
}
