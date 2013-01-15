class Fuck
{
	fun void init()
	{
		<<< "Hoolie!!!">>>;
	}
}

// define class X
class X extends Fuck
{
    // define member function
    fun void doThatThing()
    {
        <<<"Hallo">>>;
    }

    // define another
    fun void hey()
    {
        <<<"Hey!!!">>>;
    }

    // data
    int the_data;
}

// define child class Y
class Y extends X
{
    // override doThatThing()
    fun void doThatThing()
    {
        <<<"No! Get away from me!">>>;
    }
}

// instantiate a Y
Y y;

y.init();
// call doThatThing
y.doThatThing();

// call hey() - should use X's hey(), since we didn't override
y.hey();

// data is also inherited from X
<<< y.the_data >>>;