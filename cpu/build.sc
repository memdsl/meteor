import mill._
import mill.define.Sources
import mill.modules.Util
import mill.scalalib.scalafmt.ScalafmtModule
import mill.scalalib.TestModule.ScalaTest
import mill.scalalib._
import mill.bsp._

object cpu extends SbtModule with ScalafmtModule { m =>
    override def millSourcePath = os.pwd / "rtl"
    override def scalaVersion = "2.13.14"
    override def scalacOptions = Seq(
        "-language:reflectiveCalls",
        "-deprecation",
        "-feature",
        "-Xcheckinit"
    )
    override def sources = T.sources {
        super.sources() ++ Seq(PathRef(millSourcePath / "src"))
    }
    override def ivyDeps = Agg(
        ivy"org.chipsalliance::chisel:6.4.0"
    )
    override def scalacPluginIvyDeps = Agg(
        ivy"org.chipsalliance:::chisel-plugin:6.4.0"
    )
    object test extends SbtModuleTests with TestModule.ScalaTest with ScalafmtModule {
        override def sources = T.sources {
            super.sources() ++ Seq(PathRef(this.millSourcePath / "test"))
        }
        override def ivyDeps = super.ivyDeps() ++ Agg(
            ivy"edu.berkeley.cs::chiseltest:6.0.0"
        )
    }
    def repositoriesTask = T.task { Seq(
        coursier.MavenRepository("https://repo.scala-sbt.org/scalasbt/maven-releases"),
        coursier.MavenRepository("https://oss.sonatype.org/content/repositories/releases"),
        coursier.MavenRepository("https://oss.sonatype.org/content/repositories/snapshots"),
    ) ++ super.repositoriesTask() }
}
